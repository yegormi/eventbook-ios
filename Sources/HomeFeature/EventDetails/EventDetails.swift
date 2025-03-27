import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct EventDetails: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        var event: Event

        public init(event: Event) {
            self.event = event
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case view(View)

        public enum Delegate {
            case backButtonTapped
        }

        public enum View: BindableAction {
            case binding(BindingAction<EventDetails.State>)
            case onAppear
            case backButtonTapped
            case attendButtonTapped
            case showLocationButtonTapped
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { _, action in
            switch action {
            case .delegate:
                .none

            case .view(.binding):
                .none

            case .view(.onAppear):
                .none

            case .view(.backButtonTapped):
                .send(.delegate(.backButtonTapped))

            case .view(.attendButtonTapped):
                // Here you could implement ticket purchase logic
                .none

            case .view(.showLocationButtonTapped):
                // Here you could implement map navigation
                .none
            }
        }
    }
}
