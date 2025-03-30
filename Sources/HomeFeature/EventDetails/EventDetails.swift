import APIClient
import ComposableArchitecture
import Foundation
import OSLog
import SharedModels

private let logger = Logger(subsystem: "EventDetailsFeature", category: "EventDetails")

@Reducer
public struct EventDetails: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?

        var event: Event
        var similarEvents = IdentifiedArrayOf<Event>()
        var reviews = IdentifiedArrayOf<Review>()
        var isLoadingSimilarEvents = false
        var isLoadingReviews = false
        var similarEventsPageSettings = PageSettings(currentPage: 1, hasMorePages: false)
        var reviewsPageSettings = PageSettings(currentPage: 1, hasMorePages: false)

        struct PageSettings: Equatable {
            var currentPage: Int
            var hasMorePages: Bool
        }

        public init(event: Event) {
            self.event = event
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {
            case backButtonTapped
        }

        public enum Internal {
            case similarEventsResponse(Result<PaginatedResponse<Event>, Error>)
            case reviewsResponse(Result<PaginatedResponse<Review>, Error>)
        }

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<EventDetails.State>)
            case onAppear
            case backButtonTapped
            case attendButtonTapped
            case showLocationButtonTapped
            case addReviewTapped
            case similarEventTapped(Event)
            case loadMoreSimilarEvents
            case loadMoreReviews
        }
    }

    @Reducer(state: .equatable, .sendable)
    public enum Destination {
        case addReview(AddReview)
    }

    @Dependency(\.apiClient) var api
    @Dependency(\.mainQueue) var mainQueue

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case let .internal(.similarEventsResponse(result)):
                state.isLoadingSimilarEvents = false

                switch result {
                case let .success(page):
                    state.similarEventsPageSettings.hasMorePages = !page.data.isEmpty && state.similarEventsPageSettings
                        .currentPage < page.pagesCount

                    if state.similarEventsPageSettings.currentPage == 1 {
                        state.similarEvents = IdentifiedArrayOf(uniqueElements: page.data)
                    } else {
                        state.similarEvents.append(contentsOf: page.data)
                    }
                case let .failure(error):
                    logger.error("Failed to fetch similar events: \(error)")
                }
                return .none

            case let .internal(.reviewsResponse(result)):
                state.isLoadingReviews = false

                switch result {
                case let .success(page):
                    state.reviewsPageSettings.hasMorePages = !page.data.isEmpty && state.reviewsPageSettings.currentPage < page
                        .pagesCount

                    if state.reviewsPageSettings.currentPage == 1 {
                        state.reviews = IdentifiedArrayOf(uniqueElements: page.data)
                    } else {
                        state.reviews.append(contentsOf: page.data)
                    }
                case let .failure(error):
                    logger.error("Failed to fetch reviews: \(error)")
                }
                return .none

            case .view(.binding):
                return .none

            case .view(.onAppear):
                return .merge(
                    self.loadSimilarEvents(state: &state),
                    self.loadReviews(state: &state)
                )

            case .view(.backButtonTapped):
                return .send(.delegate(.backButtonTapped))

            case .view(.attendButtonTapped):
                // Here you could implement ticket purchase logic
                return .run { [eventId = state.event.id] _ in
                    do {
                        _ = try await self.api.createTicket(eventId)
                        // You could show a success message or navigate to tickets
                    } catch {
                        logger.error("Failed to create ticket: \(error)")
                        // Handle error
                    }
                }

            case .view(.showLocationButtonTapped):
                // Here you could implement map navigation
                return .none

            case .view(.addReviewTapped):
                state.destination = .addReview(AddReview.State(eventId: state.event.id))
                return .none

            case let .view(.similarEventTapped(event)):
                // Navigate to the selected similar event
                state.event = event
                state.similarEvents = []
                state.reviews = []
                state.similarEventsPageSettings = State.PageSettings(currentPage: 1, hasMorePages: false)
                state.reviewsPageSettings = State.PageSettings(currentPage: 1, hasMorePages: false)
                return .merge(
                    self.loadSimilarEvents(state: &state),
                    self.loadReviews(state: &state)
                )

            case .view(.loadMoreSimilarEvents):
                guard state.similarEventsPageSettings.hasMorePages && !state.isLoadingSimilarEvents else { return .none }
                state.similarEventsPageSettings.currentPage += 1
                return self.loadSimilarEvents(state: &state)

            case .view(.loadMoreReviews):
                guard state.reviewsPageSettings.hasMorePages && !state.isLoadingReviews else { return .none }
                state.reviewsPageSettings.currentPage += 1
                return self.loadReviews(state: &state)
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    // MARK: - Private Methods

    private func loadSimilarEvents(state: inout State) -> Effect<Action> {
        guard !state.isLoadingSimilarEvents else { return .none }
        state.isLoadingSimilarEvents = true

        let params = GetEventsParams(
            query: nil,
            page: state.similarEventsPageSettings.currentPage,
            limit: 5
        )

        return .run { [eventId = state.event.id] send in
            await send(.internal(.similarEventsResponse(Result {
                try await self.api.getSimilarEvents(eventId, params)
            })))
        }
    }

    private func loadReviews(state: inout State) -> Effect<Action> {
        guard !state.isLoadingReviews else { return .none }
        state.isLoadingReviews = true

        let params = GetReviewsParams(
            query: nil,
            limit: 10,
            page: state.reviewsPageSettings.currentPage
        )

        return .run { [eventId = state.event.id] send in
            await send(.internal(.reviewsResponse(Result {
                try await self.api.getReviewsByEventId(eventId, params)
            })))
        }
    }
}
