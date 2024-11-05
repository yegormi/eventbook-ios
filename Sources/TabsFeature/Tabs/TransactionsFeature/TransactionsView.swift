import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Transactions.self)
public struct TransactionsView: View {
    @Bindable public var store: StoreOf<Transactions>
    
    public init(store: StoreOf<Transactions>) {
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
    TransactionsView(store: Store(initialState: Transactions.State()) {
        Transactions()
    })
}
