import ComposableArchitecture
import Foundation

@Reducer
public struct Explore: Reducer {
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

        public enum Delegate: Equatable {}

        public enum Internal: Equatable {}

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Explore.State>)
            case onAppear
        }
    }

    @Reducer(state: .equatable)
    public enum Destination {}

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { _, action in
            switch action {
            case .delegate:
                .none

            case .destination:
                .none

            case .internal:
                .none

            case .view(.binding):
                .none

            case .view(.onAppear):
                .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
