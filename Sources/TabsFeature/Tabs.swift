import ComposableArchitecture
import HomeFeature
import SwiftUI

@Reducer
public struct Tabs: Reducer {
    @ObservableState
    public struct State: Equatable {
        var tab = Tab.home
        var home = Home.State()
        var transactions = Transactions.State()
        var cards = Cards.State()
        var account = Account.State()

        public init() {}

        public enum Tab: Equatable {
            case home
            case transactions
            case cards
            case account
        }
    }

    public enum Action: ViewAction {
        case home(Home.Action)
        case transactions(Transactions.Action)
        case cards(Cards.Action)
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

        Scope(state: \.transactions, action: \.transactions) {
            Transactions()
        }

        Scope(state: \.cards, action: \.cards) {
            Cards()
        }

        Scope(state: \.account, action: \.account) {
            Account()
        }

        Reduce { _, action in
            switch action {
            case .home:
                .none

            case .transactions:
                .none

            case .cards:
                .none

            case .account:
                .none

            case .view:
                .none
            }
        }
    }
}
