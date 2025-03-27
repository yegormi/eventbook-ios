import APIClient
import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct Home: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        public var events: [Event] = []
        public var isLoading = false
        public var currentPage = 1
        public var totalPages = 1
        public var searchQuery = ""
        public var isSearchActive = false

        public init() {}
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {
            case eventSelected(Event)
        }

        public enum Internal {
            case eventsResponse(Result<PaginatedResponse<Event>, Error>)
        }

        public enum View: BindableAction {
            case binding(BindingAction<Home.State>)
            case onFirstAppear
            case onAppear
            case eventTapped(Event)
            case searchCleared
            case loadPage(Int)
            case refreshEvents
        }
    }

    @Dependency(\.apiClient) var api
    @Dependency(\.uuid) var uuid
    @Dependency(\.mainQueue) var mainQueue

    private enum CancelID { case search }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case let .internal(.eventsResponse(.success(page))):
                state.isLoading = false
                state.events = page.data
                state.totalPages = page.pagesCount
                if state.totalPages == 0 { state.totalPages = 1 }
                return .none

            case .internal(.eventsResponse(.failure)):
                state.isLoading = false
                // Could add error handling here
                return .none

            case .view(.binding(\.searchQuery)):
                return self.loadEvents(state: &state)
                    .debounce(id: CancelID.search, for: .seconds(0.25), scheduler: self.mainQueue)

            case .view(.binding):
                return .none

            case .view(.onFirstAppear):
                return self.loadEvents(state: &state)

            case .view(.onAppear):
                // If events are empty, load them
                if state.events.isEmpty && !state.isLoading {
                    return self.loadEvents(state: &state)
                }
                return .none

            case let .view(.eventTapped(event)):
                return .send(.delegate(.eventSelected(event)))

            case .view(.searchCleared):
                state.searchQuery = ""
                return self.loadEvents(state: &state)

            case let .view(.loadPage(page)):
                state.currentPage = page
                return self.loadEvents(state: &state)

            case .view(.refreshEvents):
                return self.loadEvents(state: &state)
            }
        }
    }

    private func loadEvents(state: inout State) -> Effect<Action> {
        state.isLoading = true

        let params = GetEventsParams(
            query: state.searchQuery.isEmpty ? nil : state.searchQuery,
            page: state.currentPage,
            limit: 10
        )

        return .run { send in
            await send(.internal(.eventsResponse(Result {
                try await self.api.getAllEvents(params)
            })))
        }
    }
}
