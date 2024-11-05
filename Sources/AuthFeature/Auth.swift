import APIClient
import ComposableArchitecture
import Foundation
import OSLog
import SharedModels
import KeychainClient
import SessionClient
import Helpers

private let logger = Logger(subsystem: "AuthenticationFeature", category: "Auth")

@Reducer
public struct Auth: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        public init() {}

        var authType: AuthType = .signIn
        var email = ""
        var password = ""
        var confirmPassword = ""
        var isFormValid = false
        var isLoading = false
        @Presents var destination: Destination.State?
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {
            case loginSuccessful
        }

        public enum Internal {
            case loginResponse(TaskResult<LoginResponse>)
        }

        public enum View: BindableAction {
            case binding(BindingAction<Auth.State>)
            case loginButtonTapped
            case toggleButtonTapped
        }
    }

    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case alert(AlertState<Never>)
    }

    @Dependency(\.apiClient) var api

    @Dependency(\.session) var session

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case let .internal(.loginResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(loginResponse):
                    self.session.authenticate(loginResponse.user)
                    do {
                        try self.session.setCurrentAuthenticationToken(loginResponse.accessToken)
                    } catch {
                        logger.error("Failed to save the authentication token to the keychain, error: \(error)")
                    }

                    return .send(.delegate(.loginSuccessful))

                case let .failure(error):
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case .view(.binding(\.email)), .view(.binding(\.password)):
                state.isFormValid = state.email.isValidEmail && !state.password.isEmpty

                return .none

            case .view(.binding):
                return .none

            case .view(.loginButtonTapped):
                return self.login(state: &state)
                
            case .view(.toggleButtonTapped):
                state.authType.toggle()
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func login(state: inout State) -> Effect<Action> {
        guard state.isFormValid, !state.isLoading else { return .none }
        state.isLoading = true
        
        return .run { [state] send in
            await send(.internal(.loginResponse(TaskResult {
                try await self.api.login(
                    LoginRequest(email: state.email, password: state.password)
                )
            })))
        }
    }
}

extension AlertState where Action == Never {
    static func failedToAuth(error: any Error) -> Self {
        Self {
            TextState("Failed to authenticate")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState(error.localizedDescription)
        }
    }
}
