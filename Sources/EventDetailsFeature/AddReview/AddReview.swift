import APIClient
import ComposableArchitecture
import Foundation
import OSLog
import SharedModels

@Reducer
public struct AddReview: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        let eventId: String

        var title = ""
        var content = ""
        var rating = 0

        public init(eventId: String) {
            self.eventId = eventId
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case view(View)

        public enum Delegate {
            case reviewAdded(Review)
            case cancelled
        }

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<AddReview.State>)
            case cancelButtonTapped
            case submitButtonTapped
        }
    }

    @Dependency(\.apiClient) var api
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .view(.binding):
                return .none

            case .view(.cancelButtonTapped):
                return .run { _ in await self.dismiss() }

            case .view(.submitButtonTapped):
                let request = CreateReviewRequest(
                    title: state.title,
                    content: state.content,
                    rating: state.rating
                )

                return .run { [eventId = state.eventId] send in
                    do {
                        let review = try await self.api.createReview(eventId, request)
                        await send(.delegate(.reviewAdded(review)))
                    } catch {
                        // Handle error
                    }
                }
            }
        }
    }
}
