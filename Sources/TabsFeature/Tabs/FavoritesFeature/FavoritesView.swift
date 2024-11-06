import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Favorites.self)
public struct FavoritesView: View {
    @Bindable public var store: StoreOf<Favorites>

    public init(store: StoreOf<Favorites>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            EmptyTabView()
        }
        .onAppear {
            send(.onAppear)
        }
    }
}

#Preview {
    FavoritesView(store: Store(initialState: Favorites.State()) {
        Favorites()
    })
}
