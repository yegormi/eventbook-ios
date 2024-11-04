import ComposableArchitecture
import Foundation

@Reducer
public struct Cards: Reducer {
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?

        public init() {}
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate: Equatable {
        }

        public enum Internal: Equatable {
        }

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Cards.State>)
            case onAppear
        }
    }

    @Reducer(state: .equatable)
    public enum Destination {
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case .internal:
                return .none

            case .view(.binding):
                return .none

            case .view(.onAppear):
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
