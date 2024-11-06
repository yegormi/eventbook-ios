import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Cards.self)
public struct CardsView: View {
    @Bindable public var store: StoreOf<Cards>

    public init(store: StoreOf<Cards>) {
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
    CardsView(store: Store(initialState: Cards.State()) {
        Cards()
    })
}
