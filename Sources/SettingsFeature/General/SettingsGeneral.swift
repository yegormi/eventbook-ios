import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI

@Reducer
public struct SettingsGeneral: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable {
        var user: User
        var selectedAppearance: PhoneAppearance

        public init(
            user: User,
            appearance: PhoneAppearance = .system
        ) {
            self.user = user
            self.selectedAppearance = appearance
        }
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case view(View)

        public enum Delegate {
            case appearanceChanged(PhoneAppearance)
        }

        public enum View: Equatable {
            case appearanceSelected(PhoneAppearance)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case let .appearanceSelected(appearance):
                    state.selectedAppearance = appearance
                    return .send(.delegate(.appearanceChanged(appearance)))
                }

            case .delegate:
                return .none
            }
        }
    }
}
