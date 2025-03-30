import APIClient
import ComposableArchitecture
import EventDetailsFeature
import Foundation
import OSLog
import SessionClient
import SettingsFeature
import SharedModels

private let logger = Logger(subsystem: "AccountFeature", category: "Account")

@Reducer
public struct Account: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?

        var user: User
        var tab = Tab.events

        var searchQuery = ""

        var events = IdentifiedArrayOf<Event>()
        var tickets = IdentifiedArrayOf<Ticket>()
        var reviews = IdentifiedArrayOf<Review>()

        var isLoading: [Tab: Bool] = [
            .events: false,
            .tickets: false,
            .reviews: false,
        ]

        var pageSettings: [Tab: PageSettings] = [
            .events: PageSettings(currentPage: 1, hasMorePages: false),
            .tickets: PageSettings(currentPage: 1, hasMorePages: false),
            .reviews: PageSettings(currentPage: 1, hasMorePages: false),
        ]

        struct PageSettings: Equatable, Sendable {
            var currentPage: Int
            var hasMorePages: Bool
        }

        public init() {
            @Dependency(\.session) var session
            self.user = session.unsafeCurrentUser
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {}

        public enum Internal: Sendable {
            case eventsResponse(Result<PaginatedResponse<Event>, Error>)
            case ticketsResponse(Result<PaginatedResponse<Ticket>, Error>)
            case reviewsResponse(Result<PaginatedResponse<Review>, Error>)
            case refreshAllContent
            case refreshContent(Tab)
        }

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Account.State>)
            case onAppear
            case settingsButtonTapped
            case itemTapped(Tab, String, Event) // Tab, ID, Event
            case itemAppeared(Tab, String) // Tab, ID
            case refreshContent(Tab)
            case searchCleared
        }
    }

    @Reducer(state: .equatable, .sendable)
    public enum Destination {
        case settings(Settings)
        case eventDetails(EventDetails)
    }

    public enum Tab: String, Equatable, Sendable, CaseIterable {
        case events, tickets, reviews

        var title: String { self.rawValue.capitalized }
    }

    @Dependency(\.apiClient) var api
    @Dependency(\.session) var session
    @Dependency(\.mainQueue) var mainQueue

    private enum CancelID { case search }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
            .onChange(of: \.searchQuery) { _, _ in
                Reduce { state, _ in
                    .send(.internal(.refreshContent(state.tab)))
                        .debounce(id: CancelID.search, for: 0.25, scheduler: self.mainQueue)
                }
            }
            .onChange(of: \.tab) { _, newValue in
                Reduce { state, _ in
                    // Load content for the selected tab if it's empty
                    switch newValue {
                    case .events where state.events.isEmpty && !(state.isLoading[.events] ?? false):
                        self.getContent(for: .events, in: &state)
                    case .tickets where state.tickets.isEmpty && !(state.isLoading[.tickets] ?? false):
                        self.getContent(for: .tickets, in: &state)
                    case .reviews where state.reviews.isEmpty && !(state.isLoading[.reviews] ?? false):
                        self.getContent(for: .reviews, in: &state)
                    default:
                        .none
                    }
                }
            }

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case let .internal(.eventsResponse(result)):
                state.isLoading[.events] = false

                switch result {
                case let .success(response):
                    if let pageSettings = state.pageSettings[.events] {
                        let hasMorePages = !response.data.isEmpty && pageSettings.currentPage < response.pagesCount
                        state.pageSettings[.events]?.hasMorePages = hasMorePages

                        if pageSettings.currentPage == 1 {
                            state.events = IdentifiedArrayOf(uniqueElements: response.data)
                        } else {
                            state.events.append(contentsOf: response.data)
                        }
                    }

                case let .failure(error):
                    logger.error("Failed to fetch events: \(error)")
                }
                return .none

            case let .internal(.ticketsResponse(result)):
                state.isLoading[.tickets] = false

                switch result {
                case let .success(response):
                    if let pageSettings = state.pageSettings[.tickets] {
                        let hasMorePages = !response.data.isEmpty && pageSettings.currentPage < response.pagesCount
                        state.pageSettings[.tickets]?.hasMorePages = hasMorePages

                        if pageSettings.currentPage == 1 {
                            state.tickets = IdentifiedArrayOf(uniqueElements: response.data)
                        } else {
                            state.tickets.append(contentsOf: response.data)
                        }
                    }

                case let .failure(error):
                    logger.error("Failed to fetch tickets: \(error)")
                }
                return .none

            case let .internal(.reviewsResponse(result)):
                state.isLoading[.reviews] = false

                switch result {
                case let .success(response):
                    if let pageSettings = state.pageSettings[.reviews] {
                        let hasMorePages = !response.data.isEmpty && pageSettings.currentPage < response.pagesCount
                        state.pageSettings[.reviews]?.hasMorePages = hasMorePages

                        if pageSettings.currentPage == 1 {
                            state.reviews = IdentifiedArrayOf(uniqueElements: response.data)
                        } else {
                            state.reviews.append(contentsOf: response.data)
                        }
                    }

                case let .failure(error):
                    logger.error("Failed to fetch reviews: \(error)")
                }
                return .none

            case let .internal(.refreshContent(tab)):
                // Reset pagination and fetch new data for the selected tab
                state.pageSettings[tab]?.currentPage = 1
                state.pageSettings[tab]?.hasMorePages = false
                return self.getContent(for: tab, in: &state)

            case .internal(.refreshAllContent):
                // Reset pagination and fetch new data for all tabs
                for tab in Tab.allCases {
                    state.pageSettings[tab]?.currentPage = 1
                    state.pageSettings[tab]?.hasMorePages = false
                }

                return .merge(
                    self.getContent(for: .events, in: &state),
                    self.getContent(for: .tickets, in: &state),
                    self.getContent(for: .reviews, in: &state)
                )

            case .view(.binding):
                return .none

            case .view(.onAppear):
                // Load content for the selected tab if it's empty
                switch state.tab {
                case .events where state.events.isEmpty && !(state.isLoading[.events] ?? false):
                    return self.getContent(for: .events, in: &state)
                case .tickets where state.tickets.isEmpty && !(state.isLoading[.tickets] ?? false):
                    return self.getContent(for: .tickets, in: &state)
                case .reviews where state.reviews.isEmpty && !(state.isLoading[.reviews] ?? false):
                    return self.getContent(for: .reviews, in: &state)
                default:
                    return .none
                }

            case .view(.settingsButtonTapped):
                state.destination = .settings(Settings.State())
                return .none

            case let .view(.itemTapped(tab, id, event)):
                // All taps lead to EventDetails
                state.destination = .eventDetails(EventDetails.State(event: event))
                return .none

            case let .view(.itemAppeared(tab, id)):
                // If we've reached the last item, load more
                switch tab {
                case .events:
                    guard state.events.last?.id == id && !(state.isLoading[.events] ?? true) else { return .none }
                    return self.loadNextPage(for: .events, in: &state)
                case .tickets:
                    guard state.tickets.last?.id == id && !(state.isLoading[.tickets] ?? true) else { return .none }
                    return self.loadNextPage(for: .tickets, in: &state)
                case .reviews:
                    guard state.reviews.last?.id == id && !(state.isLoading[.reviews] ?? true) else { return .none }
                    return self.loadNextPage(for: .reviews, in: &state)
                }

            case .view(.searchCleared):
                state.searchQuery = ""
                return .send(.internal(.refreshContent(state.tab)))

            case let .view(.refreshContent(tab)):
                state.pageSettings[tab]?.currentPage = 1
                state.pageSettings[tab]?.hasMorePages = false
                return self.getContent(for: tab, in: &state)
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    // MARK: - Private Methods

    private func getContent(for tab: Tab, in state: inout State) -> Effect<Action> {
        guard !(state.isLoading[tab] ?? true) else { return .none }
        state.isLoading[tab] = true

        let pageSettings = state.pageSettings[tab] ?? State.PageSettings(currentPage: 1, hasMorePages: false)
        let query = state.searchQuery

        switch tab {
        case .events:
            let params = GetEventsParams(
                query: query,
                page: pageSettings.currentPage,
                limit: 10
            )

            return .run { send in
                await send(.internal(.eventsResponse(Result {
                    try await self.api.getMyEvents(params)
                })))
            }

        case .tickets:
            let params = GetTicketsParams(
                query: query,
                limit: 10,
                page: pageSettings.currentPage
            )

            return .run { send in
                await send(.internal(.ticketsResponse(Result {
                    try await self.api.getMyTickets(params)
                })))
            }

        case .reviews:
            let params = GetReviewsParams(
                query: query,
                limit: 10,
                page: pageSettings.currentPage
            )

            return .run { send in
                await send(.internal(.reviewsResponse(Result {
                    try await self.api.getMyReviews(params)
                })))
            }
        }
    }

    private func loadNextPage(for tab: Tab, in state: inout State) -> Effect<Action> {
        guard
            let pageSettings = state.pageSettings[tab],
            pageSettings.hasMorePages,
            !(state.isLoading[tab] ?? true) else { return .none }

        state.pageSettings[tab]?.currentPage += 1
        return self.getContent(for: tab, in: &state)
    }
}
