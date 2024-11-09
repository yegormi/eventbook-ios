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
        var isLoading = false

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

        public enum Internal {
            case logoutResult(Result<Void, Error>)
            case deleteResponse(Result<Void, Error>)
        }

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
        case plainAlert(AlertState<Never>)

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
                return self.logout(&state)

            case .destination(.presented(.alert(.deleteTapped))):
                return self.deleteAccount(&state)

            case .destination:
                return .none

            case let .internal(.logoutResult(result)):
                state.isLoading = false

                if case let .failure(error) = result {
                    logger.warning("Failed to log out, error: \(error)")
                    state.destination = .plainAlert(.failed(error))
                }
                return .none

            case let .internal(.deleteResponse(result)):
                state.isLoading = false

                switch result {
                case .success:
                    return self.logout(&state)
                case let .failure(error):
                    logger.warning("Failed to delete the account, error: \(error)")
                    state.destination = .plainAlert(.failed(error))
                }
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

    private func logout(_ state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true

        return .run { send in
            await send(.internal(.logoutResult(Result {
                try self.session.logout()
            })))
        }
    }

    private func deleteAccount(_ state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true

        return .run { send in
            await send(.internal(.deleteResponse(Result {
                try await self.api.deleteCurrentUser()
            })))
        }
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

extension AlertState where Action == Never {
    static func failed(_ error: any Error) -> Self {
        Self {
            TextState("Failed to perform action")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState(error.localizedDescription)
        }
    }
}
