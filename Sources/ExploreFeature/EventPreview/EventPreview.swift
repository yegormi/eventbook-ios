import ComposableArchitecture
import Foundation
import OSLog
import SharedModels

@Reducer
public struct EventPreview: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        let event: Event

        public init(event: Event) {
            self.event = event
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case view(View)

        public enum Delegate: Equatable, Sendable {
            case viewDetailsButtonTapped
            case dismissButtonTapped
        }

        public enum View: Equatable, Sendable {
            case viewDetailsButtonTapped
            case dismissButtonTapped
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .delegate:
                .none

            case .view(.viewDetailsButtonTapped):
                .send(.delegate(.viewDetailsButtonTapped))

            case .view(.dismissButtonTapped):
                .send(.delegate(.dismissButtonTapped))
            }
        }
    }
}
