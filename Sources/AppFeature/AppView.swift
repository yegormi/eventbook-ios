import AuthFeature
import ComposableArchitecture
import SplashFeature
import SwiftUI
import TabsFeature

public struct AppView: View {
    let store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        Group {
            switch self.store.destination {
            case .splash:
                SplashScreen()
            case .auth:
                if let store = self.store.scope(state: \.destination.auth, action: \.destination.auth) {
                    AuthView(store: store)
                }
            case .tabs:
                if let store = self.store.scope(state: \.destination.tabs, action: \.destination.tabs) {
                    TabsView(store: store)
                }
            }
        }
        .animation(.smooth, value: self.store.destination)
        .task { await self.store.send(.task).finish() }
    }
}

#Preview {
    AppView(store: Store(initialState: AppReducer.State()) {
        AppReducer()
    })
}
