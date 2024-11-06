import AuthFeature
import ComposableArchitecture
import Dependencies
import OSLog
import SplashFeature
import TabsFeature

private let logger = Logger(subsystem: "AppFeature", category: "AppReducer")

@Reducer
public struct AppReducer: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        var destination = Destination.State.splash

        public init() {}
    }

    public enum Action {
        case destination(Destination.Action)
        case changeToDestination(Destination.State)
        case task
    }

    @Reducer(state: .equatable)
    public enum Destination {
        @ReducerCaseIgnored
        case splash
        case auth(AuthFeature)
        case tabs(Tabs)
    }

    @Dependency(\.apiClient) var api

    @Dependency(\.session) var session

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }

        Reduce { state, action in
            switch action {
            case .destination:
                return .none

            case let .changeToDestination(destination):
                state.destination = destination
                return .none

            case .task:
                return .run { send in
                    do {
                        if let storedAuthToken = try self.session.currentAuthenticationToken() {
                            logger.info("Found authentication token in keychain, attempting to login...")
                            try self.session.setCurrentAuthenticationToken(storedAuthToken)
                            let currentUser = try await self.api.getCurrentUser()
                            self.session.authenticate(currentUser)
                            logger.info("Logged in successfully!")
                            await send(.changeToDestination(.tabs(Tabs.State())))
                        } else {
                            await send(.changeToDestination(.auth(AuthFeature.State())))
                            logger.info("Did not find a stored authentication token, showing login screen.")
                        }
                    } catch {
                        logger.warning("An error occurred while trying to sign the user in: \(error)")
                        await send(.changeToDestination(.auth(AuthFeature.State())))
                        try self.session.logout()
                    }

                    await send(.changeToDestination(.tabs(Tabs.State())))

                    // Logout
                    for await user in self.session.currentUsers() where user == nil {
                        await send(.changeToDestination(.auth(AuthFeature.State())))
                    }
                }
            }
        }
    }
}
