import APIClient
import ComposableArchitecture
import CryptoKit
import FacebookClient
import FacebookCore
import FacebookLogin
import Foundation
import GoogleClient
import GoogleSignIn
import KeychainClient
import OSLog
import SessionClient
import SharedModels
import Supabase
import SupabaseSwiftClient
import SwiftHelpers

private let logger = Logger(subsystem: "AuthenticationFeature", category: "Auth")

@Reducer
public struct AuthFeature: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        public init() {}

        var authType: AuthType = .signIn
        var email = ""
        var password = ""
        var confirmPassword = ""
        var rawNonce = ""
        var isLoading = false
        @Presents var destination: Destination.State?

        /// Checks if the form inputs are valid based on the authentication type:
        /// - Requires a valid email format and non-empty password.
        /// - For `.signIn`, only email and password are required.
        /// - Otherwise, `password` must match `confirmPassword`.
        var isFormValid: Bool {
            guard self.email.isValidEmail, !self.password.isEmpty else { return false }
            return self.authType == .signIn || self.password == self.confirmPassword
        }

        mutating func regenerateNonce() {
            self.rawNonce = randomNonceString()
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
            case localAuthResponse(Result<Void, Error>)
            case supabaseResponse(Result<Session, Error>)
            case googleResponse(Result<GoogleUser, Error>)
            case facebookResponse(Result<String, Error>)
        }

        public enum View: BindableAction {
            case binding(BindingAction<AuthFeature.State>)
            case toggleButtonTapped
            case loginButtonTapped
            case signupButtonTapped
            case providerButtonTapped(AuthServiceType)
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

    @Dependency(\.supabaseClient) var supabase

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case let .internal(.localAuthResponse(result)):
                switch result {
                case .success:
                    logger.info("Authenticated the user successfully!")
                    return .send(.delegate(.authSuccessful))
                case let .failure(error):
                    logger.error("Failed to perform an action, error: \(error)")
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case let .internal(.supabaseResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(response):
                    return .run { send in
                        await send(.internal(.localAuthResponse(Result {
                            try self.session.setCurrentAccessToken(response.accessToken)
                            let user = try await self.api.getCurrentUser()
                            self.session.authenticate(user)
                        })))
                    }
                case let .failure(error):
                    logger.error("Failed to login with Supabase, error: \(error)")
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case let .internal(.googleResponse(result)):
                state.isLoading = false

                switch result {
                case let .success(user):
                    state.isLoading = true
                    let credential = OpenIDConnectCredentials(
                        provider: .google,
                        idToken: user.idToken,
                        accessToken: user.accessToken
                    )

                    return .run { send in
                        await send(.internal(.supabaseResponse(Result {
                            try await self.supabase.signInWithIdToken(credentials: credential)
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
                    state.isLoading = true
                    let credential = OpenIDConnectCredentials(
                        provider: .facebook,
                        idToken: accessToken,
                        nonce: state.rawNonce
                    )
                    return .run { send in
                        await send(.internal(.supabaseResponse(Result {
                            try await self.supabase.signInWithIdToken(credentials: credential)
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

            case let .view(.providerButtonTapped(service)):
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
                    state.regenerateNonce()

                    return .run { [state] send in
                        await send(.internal(.facebookResponse(Result {
                            try await self.facebook.authenticate(hashedNonce: sha256(state.rawNonce))
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
            await send(.internal(.supabaseResponse(Result {
                try await self.supabase.signIn(
                    email: state.email,
                    password: state.password
                )
            })))
        }
    }

    private func signup(_ state: inout State) -> Effect<Action> {
        guard state.isFormValid, !state.isLoading else { return .none }
        state.isLoading = true

        return .run { [state] send in
            await send(.internal(.supabaseResponse(Result {
                try await self.supabase.signUp(
                    email: state.email,
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
