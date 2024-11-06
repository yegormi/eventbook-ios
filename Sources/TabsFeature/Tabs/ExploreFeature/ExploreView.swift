import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Explore.self)
public struct ExploreView: View {
    @Bindable public var store: StoreOf<Explore>

    public init(store: StoreOf<Explore>) {
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
    ExploreView(store: Store(initialState: Explore.State()) {
        Explore()
    })
}
