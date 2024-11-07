import APIClient
import ComposableArchitecture
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

    @Dependency(\.authGoogle) var authGoogle

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
                    do {
                        try self.session.authenticate(response.toUser())
                        _ = Task { @MainActor in
                            let token = try await response.user.getIDToken()
                            try self.session.setCurrentAuthenticationToken(token)
                        }
                    } catch {
                        logger.error("Failed to authenticate the user, error: \(error)")
                    }

                    return .send(.delegate(.authSuccessful))

                case let .failure(error):
                    state.destination = .alert(.failedToAuth(error: error))
                    return .none
                }

            case let .internal(.googleResponse(result)):
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

    private func googleAuth(_: inout State) -> Effect<Action> {
        .run { send in
            await send(.internal(.googleResponse(Result {
                try await self.authGoogle.authenticate()
            })))
        }
    }

    private func facebookAuth(_: inout State) -> Effect<Action> {
        .none
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
