import ComposableArchitecture
import Foundation
import Styleguide
import SwiftHelpers
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Home.self)
public struct HomeView: View {
    @Bindable public var store: StoreOf<Home>

    public init(store: StoreOf<Home>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            EmptyTabView()
        }
        .onFirstAppear {
            send(.onFirstAppear)
        }
        .onAppear {
            send(.onAppear)
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
