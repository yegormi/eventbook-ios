import ComposableArchitecture
import Foundation
import SharedModels
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
        ScrollView {
            VStack(spacing: 30) {
                self.avatarCell(for: self.store.user)

                VStack(spacing: 20) {
                    Button("Logout") {
                        send(.logoutButtonTapped)
                    }
                    .buttonStyle(.primary(size: .fullWidth))

                    Button("Delete account") {
                        send(.deleteButtonTapped)
                    }
                    .foregroundStyle(Color.red)
                    .font(.labelMedium)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentMargins(.all, 16, for: .scrollContent)
        .onAppear {
            send(.onAppear)
        }
        .alert(
            store: self.store.scope(state: \.$destination.alert, action: \.destination.alert)
        )
    }

    @ViewBuilder
    private func avatarCell(for user: SharedModels.User) -> some View {
        HStack(spacing: 12) {
            self.userAvatar(for: user)
                .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 5) {
                Text(user.fullName ?? "No username provided")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(user.email ?? "No email registered")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.neutral500)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func userAvatar(for user: SharedModels.User) -> some View {
        if let pictureURL = user.photoURL {
            AsyncImage(url: pictureURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } placeholder: {
                self.placeholderAvatar(for: user)
            }
        } else {
            self.placeholderAvatar(for: user)
        }
    }

    @ViewBuilder
    private func placeholderAvatar(for user: User) -> some View {
        Circle()
            .foregroundStyle(Color.neutral200)
            .overlay {
                Text(user.fullName?.first?.uppercased() ?? "")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.neutral500)
            }
    }
}

#Preview {
    AccountView(store: Store(initialState: Account.State()) {
        Account()
    })
}
