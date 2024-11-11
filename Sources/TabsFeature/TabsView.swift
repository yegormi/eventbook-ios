import AccountFeature
import ComposableArchitecture
import HomeFeature
import Styleguide
import SwiftHelpers
import SwiftUI

public struct TabsView: View {
    @Bindable public var store: StoreOf<Tabs>

    public init(store: StoreOf<Tabs>) {
        self.store = store

        // Configure tab bar layout
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowImage = UIColor(Color.black.opacity(0.3)).image(size: CGSize(width: 1.0, height: 0.3))
        appearance.shadowColor = nil

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    public var body: some View {
        TabView(selection: self.$store.tab) {
            NavigationStack {
                HomeView(
                    store: self.store.scope(state: \.home, action: \.home)
                )
                .background(Color(uiColor: UIColor.systemBackground))
                .navigationTitle("Home")
                .toolbarTitleDisplayMode(.large)
            }
            .tag(Tabs.State.Tab.home)
            .tabItem {
                Label("Home", image: .homeTab)
            }

            NavigationStack {
                ExploreView(
                    store: self.store.scope(state: \.explore, action: \.explore)
                )
                .background(Color(uiColor: UIColor.systemBackground))
                .navigationTitle("Explore")
                .toolbarTitleDisplayMode(.large)
            }
            .tag(Tabs.State.Tab.explore)
            .tabItem {
                Label("Explore", image: .exploreTab)
            }

            NavigationStack {
                FavoritesView(
                    store: self.store.scope(state: \.favorites, action: \.favorites)
                )
                .background(Color(uiColor: UIColor.systemBackground))
                .navigationTitle("Favorites")
                .toolbarTitleDisplayMode(.large)
            }
            .tag(Tabs.State.Tab.favorites)
            .tabItem {
                Label("Favorites", image: .favoritesTab)
            }

            NavigationStack {
                AccountView(
                    store: self.store.scope(state: \.account, action: \.account)
                )
                .background(Color(uiColor: UIColor.systemBackground))
                .navigationTitle("Account")
                .toolbarTitleDisplayMode(.large)
            }
            .tag(Tabs.State.Tab.account)
            .tabItem {
                Label("Account", image: .accountTab)
            }
        }
//        .introspect(.tabView, on: .iOS(.v17)) { tabBarController in
//            for viewControllers in tabBarController.viewControllers ?? [] {
//                viewControllers.tabBarItem.imageInsets = .init(top: 3, left: 0, bottom: -3, right: 0)
//            }
//        }
    }
}

#Preview {
    TabsView(store: Store(initialState: Tabs.State()) {
        Tabs()
    })
}
