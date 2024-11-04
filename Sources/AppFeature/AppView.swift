import ComposableArchitecture
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
            case .loading:
                ProgressView()
                    .scaleEffect(1.5)
            case .tabs:
                if let store = self.store.scope(state: \.destination.tabs, action: \.destination.tabs) {
                    TabsView(store: store)
                }
                
            }
        }
        .task { await self.store.send(.task).finish() }
    }
        
}

#Preview {
    AppView(store: Store(initialState: AppReducer.State()) {
        AppReducer()
    })
}
