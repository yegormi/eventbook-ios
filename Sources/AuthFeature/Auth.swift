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
        var isLoading = false
        @Presents var destination: Destination.State?
        
        var isFormValid: Bool {
            guard self.email.isValidEmail else { return false }
            
            if self.authType == .signIn {
                return !self.password.isEmpty
            } else {
                return !self.password.isEmpty && self.password == self.confirmPassword
            }
        }
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
            case signupResponse(TaskResult<SignupResponse>)
        }

        public enum View: BindableAction {
            case binding(BindingAction<Auth.State>)
            case toggleButtonTapped
            case loginButtonTapped
            case signupButtonTapped
            case authServiceButtonTapped(AuthServiceType)
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
                
            case let .internal(.signupResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(signupResponse):
                    self.session.authenticate(signupResponse.user)
                    do {
                        try self.session.setCurrentAuthenticationToken(signupResponse.accessToken)
                    } catch {
                        logger.error("Failed to save the authentication token to the keychain, error: \(error)")
                    }

                    return .send(.delegate(.loginSuccessful))

                case let .failure(error):
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case .view(.binding):
                return .none
                
            case .view(.toggleButtonTapped):
                state.authType.toggle()
                state.confirmPassword = ""
                return .none

            case .view(.loginButtonTapped):
                return self.login(&state)
                
            case .view(.signupButtonTapped):
                return self.signup(&state)
                
            case let .view(.authServiceButtonTapped(service)):
                switch service {
                case .google:
                    return self.googleAuth(&state)
                case .facebook:
                    return self.facebookAuth(&state)
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func login(_ state: inout State) -> Effect<Action> {
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
    
    private func signup(_ state: inout State) -> Effect<Action> {
        guard state.isFormValid, !state.isLoading else { return .none }
        state.isLoading = true
        
        return .run { [state] send in
            await send(.internal(.signupResponse(TaskResult {
                try await self.api.signup(
                    SignupRequest(email: state.email, password: state.password)
                )
            })))
        }
    }
    
    private func googleAuth(_ state: inout State) -> Effect<Action> {
        return .none
    }
    
    private func facebookAuth(_ state: inout State) -> Effect<Action> {
        return .none
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
