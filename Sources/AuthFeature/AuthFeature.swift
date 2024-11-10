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
            case firebaseResponse(Result<AuthDataResult, Error>)
            case loginResponse(Result<LoginResponse, Error>)
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

            case let .internal(.firebaseResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(response):
                    state.isLoading = true

                    return .run { send in
                        await send(.internal(.loginResponse(Result {
                            let token = try await response.user.getIDToken()
                            try self.session.setCurrentIDToken(token)
                            return try await self.api.login(LoginRequest(idToken: token))
                        })))
                    }
                case let .failure(error):
                    logger.error("Failed to authenticate with Firebase, error: \(error)")
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case let .internal(.loginResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(response):
                    do {
                        try self.session.setCurrentAccessToken(response.accessToken)
                    } catch {
                        logger.error("Failed to save access token to the keychain, error: \(error)")
                    }
                    self.session.authenticate(response.user)
                    logger.info("Authenticated the user session locally!")
                    return .send(.delegate(.authSuccessful))

                case let .failure(error):
                    logger.error("Failed to login, error: \(error)")
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
                    state.isLoading = true

                    return .run { send in
                        await send(.internal(.firebaseResponse(Result {
                            try await Auth.auth().signIn(with: credential)
                        })))
                    }

                case let .failure(error):
                    logger.error("Failed to authenticate with Google, error: \(error)")
                    if !error.isUserCancelled {
                        state.destination = .alert(.failedToAuth(error: error))
                    }
                    return .none
                }

            case let .internal(.facebookResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(accessToken):
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                    state.isLoading = true

                    return .run { send in
                        await send(.internal(.firebaseResponse(Result {
                            try await Auth.auth().signIn(with: credential)
                        })))
                    }

                case let .failure(error):
                    logger.error("Failed to authenticate with Facebook: \(error)")
                    if !error.isUserCancelled {
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
                guard !state.isLoading else { return .none }
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
            await send(.internal(.firebaseResponse(Result {
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
            await send(.internal(.firebaseResponse(Result {
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

extension Error {
    var isUserCancelled: Bool {
        if let googleError = self as? GIDSignInError, googleError.code == .canceled { return true }
        if let fbError = self as? FacebookAuthError, fbError == .canceled { return true }
        return false
    }
}
