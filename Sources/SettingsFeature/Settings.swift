import APIClient
import AppearanceClient
import ComposableArchitecture
import Foundation
import OSLog
import SessionClient
import SharedModels

private let logger = Logger(subsystem: "SettingsFeature", category: "Settings")

@Reducer
public struct Settings: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        public enum Tab: Equatable {
            case general, account, security
        }

        @Presents var destination: Destination.State?

        var user: User
        var tab = Tab.general

        var general: SettingsGeneral.State
        var account: SettingsAccount.State

        public init() {
            @Dependency(\.appearance) var appearance
            @Dependency(\.session) var session
            let user = session.unsafeCurrentUser

            self.user = user
            self.general = SettingsGeneral.State(
                user: user,
                appearance: appearance.currentAppearance()
            )
            self.account = SettingsAccount.State(user: user)
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)
        case general(SettingsGeneral.Action)
        case account(SettingsAccount.Action)

        public enum Delegate {}

        public enum Internal {
            case appearanceUpdate(Result<Void, Error>)
        }

        public enum View: Equatable, BindableAction {
            case binding(BindingAction<Settings.State>)
        }
    }

    @Reducer(state: .equatable, .sendable)
    public enum Destination {}

    @Dependency(\.apiClient) var api

    @Dependency(\.session) var session

    @Dependency(\.appearance) var appearance

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Scope(state: \.general, action: \.general) {
            SettingsGeneral()
        }

        Scope(state: \.account, action: \.account) {
            SettingsAccount()
        }

        Reduce { _, action in
            switch action {
            case .delegate:
                return .none

            case .destination:
                return .none

            case let .internal(.appearanceUpdate(response)):
                switch response {
                case .success:
                    logger.info("Appearance updated successfully")
                case let .failure(error):
                    logger.error("Failed to update appearance: \(error)")
                }

                return .none

            case .view(.binding):
                return .none

            case let .general(.delegate(.appearanceChanged(newAppearance))):
                logger.info("Changing appearance to: \(newAppearance.rawValue)")

                return .run { send in
                    await send(.internal(.appearanceUpdate(Result {
                        await self.appearance.setAppearance(newAppearance)
                    })))
                }

            case .general:
                return .none

            case .account:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
