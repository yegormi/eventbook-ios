import APIClient
import ComposableArchitecture
import Foundation
import OSLog
import SessionClient
import SettingsFeature
import SharedModels

private let logger = Logger(subsystem: "AccountFeature", category: "Account")

@Reducer
public struct Account: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?

        var user: User
        var tab = Tab.events

        public enum Tab: String, Equatable, CaseIterable {
            case events, tickets, reviews

            var title: String { self.rawValue.capitalized }
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

        public enum Internal {}

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Account.State>)
            case onAppear
            case settingsButtonTapped
        }
    }

    @Reducer(state: .equatable)
    public enum Destination {
        case settings(Settings)
    }

    @Dependency(\.apiClient) var api

    @Dependency(\.session) var session

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

            case .view(.settingsButtonTapped):
                state.destination = .settings(Settings.State())
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
