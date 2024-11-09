import APIClient
import ComposableArchitecture
import FacebookClient
import FacebookCore
import FacebookLogin
@preconcurrency import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleClient
import GoogleSignIn
import Helpers
import KeychainClient
import OSLog
import SessionClient
import SharedModels

private let logger = Logger(subsystem: "AuthenticationFeature", category: "Auth")
private struct MissingAccessTokenError: Error {}

@Reducer
public struct AuthFeature: Reducer, Sendable {
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
            case authSuccessful
        }

        public enum Internal {
            case authResponse(Result<AuthDataResult, Error>)
            case googleResponse(Result<GoogleUser, Error>)
            case facebookResponse(Result<String, Error>)
        }

        public enum View: BindableAction {
            case binding(BindingAction<AuthFeature.State>)
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

    @Dependency(\.authGoogle) var google

    @Dependency(\.authFacebook) var facebook

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case let .internal(.authResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(response):
                    return .run { send in
                        do {
                            let token = try await response.user.getIDToken()
                            let response = try await self.api.login(LoginRequest(idToken: token))
                            logger.info("Logged in the user successfully!")

                            self.session.authenticate(response.user)
                            try self.session.setCurrentIDToken(token)
                            try self.session.setCurrentAccessToken(response.accessToken)

                            logger.info("Authenticated the user locally!")
                            await send(.delegate(.authSuccessful))
                        } catch {
                            logger.error("Failed to authenticate the user, error: \(error)")
                        }
                    }
                case let .failure(error):
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case let .internal(.googleResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(user):
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: user.idToken,
                        accessToken: user.accessToken
                    )

                    return .run { send in
                        await send(.internal(.authResponse(Result {
                            try await Auth.auth().signIn(with: credential)
                        })))
                    }

                case let .failure(error):
                    if let googleError = error as? GIDSignInError, googleError.code != .canceled {
                        state.destination = .alert(.failedToAuth(error: error))
                    }
                    return .none
                }

            case let .internal(.facebookResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(accessToken):
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)

                    return .run { send in
                        await send(.internal(.authResponse(Result {
                            try await Auth.auth().signIn(with: credential)
                        })))
                    }

                case let .failure(error):
                    if let fbError = error as? FacebookAuthError, fbError != .canceled {
                        state.destination = .alert(.failedToAuth(error: error))
                    }
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
                state.isLoading = true

                switch service {
                case .google:
                    return .run { send in
                        await send(.internal(.googleResponse(Result {
                            try await self.google.authenticate()
                        })))
                    }
                case .facebook:
                    return .run { send in
                        await send(.internal(.facebookResponse(Result {
                            try await self.facebook.authenticate()
                        })))
                    }
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func login(_ state: inout State) -> Effect<Action> {
        guard state.isFormValid, !state.isLoading else { return .none }
        state.isLoading = true

        return .run { [state] send in
            await send(.internal(.authResponse(Result {
                try await Auth.auth().signIn(
                    withEmail: state.email,
                    password: state.password
                )
            })))
        }
    }

    private func signup(_ state: inout State) -> Effect<Action> {
        guard state.isFormValid, !state.isLoading else { return .none }
        state.isLoading = true

        return .run { [state] send in
            await send(.internal(.authResponse(Result {
                try await Auth.auth().createUser(
                    withEmail: state.email,
                    password: state.password
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
