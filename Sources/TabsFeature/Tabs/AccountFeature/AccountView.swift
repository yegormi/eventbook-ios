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
        VStack(spacing: 30) {
            EmptyTabView()

            Button("Logout") {
                send(.logoutButtonTapped)
            }
            .buttonStyle(.primary(size: .small))
        }
        .onAppear {
            send(.onAppear)
        }
        .alert(
            store: self.store.scope(state: \.$destination.alert, action: \.destination.alert)
        )
    }
}

#Preview {
    AccountView(store: Store(initialState: Account.State()) {
        Account()
    })
}
