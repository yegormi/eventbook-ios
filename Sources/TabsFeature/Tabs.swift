import ComposableArchitecture
import HomeFeature
import SwiftUI

@Reducer
public struct Tabs: Reducer {
    @ObservableState
    public struct State: Equatable {
        var tab = Tab.home
        var home = Home.State()
        var explore = Explore.State()
        var favorites = Favorites.State()
        var account = Account.State()

        public init() {}

        public enum Tab: Equatable {
            case home
            case explore
            case favorites
            case account
        }
    }

    public enum Action: ViewAction {
        case home(Home.Action)
        case explore(Explore.Action)
        case favorites(Favorites.Action)
        case account(Account.Action)

        case view(View)

        public enum View: BindableAction, Equatable {
            case binding(BindingAction<State>)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Scope(state: \.home, action: \.home) {
            Home()
        }

        Scope(state: \.explore, action: \.explore) {
            Explore()
        }

        Scope(state: \.favorites, action: \.favorites) {
            Favorites()
        }

        Scope(state: \.account, action: \.account) {
            Account()
        }

        Reduce { _, action in
            switch action {
            case .home:
                .none

            case .explore:
                .none

            case .favorites:
                .none

            case .account:
                .none

            case .view:
                .none
            }
        }
    }
}
