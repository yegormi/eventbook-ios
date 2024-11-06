import APIClientLive
import ComposableArchitecture
import Foundation
import SharedModels

@Reducer
public struct Home: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {}

        public enum Internal {}

        public enum View: BindableAction {
            case binding(BindingAction<Home.State>)
            case onFirstAppear
            case onAppear
        }
    }

    @Dependency(\.apiClient) var api

    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { _, action in
            switch action {
            case .delegate:
                .none

            case .internal:
                .none

            case .view(.binding):
                .none

            case .view(.onFirstAppear):
                .none

            case .view(.onAppear):
                .none
            }
        }
    }
}
