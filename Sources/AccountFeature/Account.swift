import APIClient
import ComposableArchitecture
import Foundation
import OSLog
import SessionClient
import SharedModels

private let logger = Logger(subsystem: "AccountFeature", category: "Account")

@Reducer
public struct Account: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?

        var user: User

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

        public enum Delegate: Equatable {}

        public enum Internal: Equatable {}

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Account.State>)
            case onAppear
            case logoutButtonTapped
            case deleteButtonTapped
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)

        public enum Alert: Equatable, Sendable {
            case logoutTapped
            case deleteTapped
        }
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

            case .destination(.presented(.alert(.logoutTapped))):
                return .run { _ in
                    do {
                        try self.session.logout()
                    } catch {
                        logger.warning("Failed to log out, error: \(error)")
                    }
                }

            case .destination(.presented(.alert(.deleteTapped))):
                return .run { _ in
                    do {
                        try await self.api.deleteCurrentUser()
                        try self.session.logout()
                    } catch {
                        logger.warning("Failed to delete the account, error: \(error)")
                    }
                }

            case .destination:
                return .none

            case .internal:
                return .none

            case .view(.binding):
                return .none

            case .view(.onAppear):
                return .none

            case .view(.logoutButtonTapped):
                state.destination = .alert(.logoutAccount)
                return .none

            case .view(.deleteButtonTapped):
                state.destination = .alert(.deleteAccount)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == Account.Destination.Alert {
    static let logoutAccount = Self {
        TextState("Confirm")
    } actions: {
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
        ButtonState(role: .destructive, action: .logoutTapped) {
            TextState("Log out")
        }
    } message: {
        TextState("Are you sure you want to log out? This action cannot be undone.")
    }
}

extension AlertState where Action == Account.Destination.Alert {
    static let deleteAccount = Self {
        TextState("Confirm")
    } actions: {
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
        ButtonState(role: .destructive, action: .deleteTapped) {
            TextState("Delete account")
        }
    } message: {
        TextState("Are you sure you want to delete your account? This action cannot be undone.")
    }
}
