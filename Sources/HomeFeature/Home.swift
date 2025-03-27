import APIClient
import ComposableArchitecture
import Foundation
import OSLog
import SharedModels

private let logger = Logger(subsystem: "HomeFeature", category: "Home")

@Reducer
public struct Home: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?

        struct PageSettings: Equatable {
            var currentPage: Int
            var hasMorePages: Bool
        }

        var pageSettings = PageSettings(currentPage: 1, hasMorePages: false)
        var events = IdentifiedArrayOf<Event>()
        var isLoading = false
        var searchQuery = ""
        var isSearchActive = false

        public init() {}
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {
            case eventSelected(Event)
        }

        public enum Internal {
            case eventsResponse(Result<PaginatedResponse<Event>, Error>)
            case refreshEventsList
        }

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Home.State>)
            case onFirstAppear
            case onAppear
            case eventAppeared(String)
            case eventTapped(Event)
            case searchCleared
            case loadPage(Int)
            case refreshEvents
        }
    }

    @Reducer(state: .equatable, .sendable)
    public enum Destination {
        case eventDetails(EventDetails)
    }

    @Dependency(\.apiClient) var api
    @Dependency(\.uuid) var uuid
    @Dependency(\.mainQueue) var mainQueue

    private enum CancelID { case search }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
            .onChange(of: \.searchQuery) { _, _ in
                Reduce { _, _ in
                    .send(.internal(.refreshEventsList))
                        .debounce(id: CancelID.search, for: 0.25, scheduler: self.mainQueue)
                }
            }

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination(.presented(.eventDetails(.delegate(.backButtonTapped)))):
                state.destination = nil
                return .none

            case .destination:
                return .none

            case let .internal(.eventsResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(page):
                    state.pageSettings.hasMorePages = !page.data.isEmpty && state.pageSettings.currentPage < page.pagesCount

                    if state.pageSettings.currentPage == 1 {
                        state.events = IdentifiedArrayOf(uniqueElements: page.data)
                    } else {
                        state.events.append(contentsOf: page.data)
                    }
                case let .failure(error):
                    logger.error("Failed to fetch events: \(error)")
                }
                return .none

            case .internal(.refreshEventsList):
                state.pageSettings = State.PageSettings(currentPage: 1, hasMorePages: false)
                return self.getEvents(&state)

            case .view(.binding):
                return .none

            case .view(.onFirstAppear), .view(.onAppear):
                if state.events.isEmpty && !state.isLoading {
                    return self.getEvents(&state)
                }
                return .none

            case let .view(.eventAppeared(eventId)):
                guard state.events.last?.id == eventId else { return .none }
                return self.loadNextPage(&state)

            case let .view(.eventTapped(event)):
                state.destination = .eventDetails(EventDetails.State(event: event))
                return .none

            case .view(.searchCleared):
                state.searchQuery = ""
                return .send(.internal(.refreshEventsList))

            case let .view(.loadPage(page)):
                state.pageSettings.currentPage = page
                return self.getEvents(&state)

            case .view(.refreshEvents):
                return .send(.internal(.refreshEventsList))
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    // MARK: - Private Methods

    private func getEvents(_ state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true

        let params = GetEventsParams(
            query: state.searchQuery.isEmpty ? nil : state.searchQuery,
            page: state.pageSettings.currentPage,
            limit: 10
        )

        return .run { send in
            await send(.internal(.eventsResponse(Result {
                try await self.api.getAllEvents(params)
            })))
        }
    }

    private func loadNextPage(_ state: inout State) -> Effect<Action> {
        guard !state.isLoading, state.pageSettings.hasMorePages else { return .none }
        state.pageSettings.currentPage += 1
        return self.getEvents(&state)
    }
}
