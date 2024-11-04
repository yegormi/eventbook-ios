import ComposableArchitecture
import Foundation
import Helpers
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Home.self)
public struct HomeView: View {
    @Bindable public var store: StoreOf<Home>

    public init(store: StoreOf<Home>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CardView {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(.eurFlag)
                            Text("EUR account")
                                .font(.labelLarge)
                                .foregroundStyle(Color.neutral500)
                        }
                        Text((self.store.balance?.balance ?? 0.0).toCurrency())
                            .font(.headlineMedium)
                            .foregroundStyle(Color.neutral900)
                    }
                }

                CardView {
                    HStack {
                        Text("My cards")
                            .font(.headlineSmall)
                            .foregroundStyle(Color.neutral800)
                        Spacer()
                        Button("See all") {}
                    }
                } content: {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(self.store.cards) { card in
                            AppCardCell(card: card)
                        }
                    }
                }

                CardView {
                    HStack {
                        Text("Recent transactions")
                            .font(.headlineSmall)
                            .foregroundStyle(Color.neutral800)
                        Spacer()
                        Button("See all") {}
                    }
                } content: {
                    VStack(spacing: 8) {
                        ForEach(store.transactions) { transaction in
                            CardTransactionCell(transaction: transaction)
                        }
                    }
                }

            }
            .padding(.top, 24)
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    send(.withdrawalButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
        .sheet(
            item: self.$store.scope(state: \.destination?.withdrawal, action: \.destination.withdrawal)
        ) { store in
            NavigationStack {
                WithdrawalView(store: store)
                    .padding(16)
                    .background(Color.appBackground)
                    .navigationTitle("Transfer")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                send(.closeWithdrawalButtonTapped)
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
            }
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
