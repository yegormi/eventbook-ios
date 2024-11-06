import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Account.self)
public struct AccountView: View {
    @Bindable public var store: StoreOf<Account>

    public init(store: StoreOf<Account>) {
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
    AccountView(store: Store(initialState: Account.State()) {
        Account()
    })
}
