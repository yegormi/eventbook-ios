import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: SettingsAccount.self)
public struct SettingsAccountView: View {
    @Bindable public var store: StoreOf<SettingsAccount>

    public init(store: StoreOf<SettingsAccount>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 50) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Update your profile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack { Divider().overlay(Color.secondary) }

                    self.userAvatar(for: self.store.user)
                        .frame(width: 150, height: 150)

                    VStack(spacing: 14) {
                        TextField("Full name", text: self.$store.fullName)
                            .textFieldStyle(.auth)
                            .textContentType(.name)

                        TextField("Email", text: self.$store.email)
                            .textFieldStyle(.auth)
                            .textContentType(.emailAddress)
                            .disabled(true)

                        PasswordField("Password", text: self.$store.password)
                            .textFieldStyle(.auth)
                            .textContentType(.password)
                            .disabled(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button("Update") {
                        send(.updateButtonTapped)
                    }
                    .buttonStyle(.primary(size: .fullWidth))

                    Button("Reset") {
                        send(.resetButtonTapped)
                    }
                    .buttonStyle(.secondary(size: .fullWidth))
                }

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Actions")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Manage your account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack { Divider().overlay(Color.secondary) }

                    VStack(spacing: 20) {
                        Button("Sign out") {
                            send(.logoutButtonTapped)
                        }
                        .buttonStyle(.destructive(size: .fullWidth))

                        Button("Delete account") {
                            send(.deleteButtonTapped)
                        }
                        .font(.labelMedium)
                        .buttonStyle(.destructive(size: .fullWidth, variant: .outlined))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentMargins(.all, 16, for: .scrollContent)
        .onAppear {
            send(.onAppear)
        }
        .isLoading(self.store.isLoading)
        .alert(
            store: self.store.scope(state: \.$destination.alert, action: \.destination.alert)
        )
        .alert(
            store: self.store.scope(state: \.$destination.plainAlert, action: \.destination.plainAlert)
        )
    }

    @ViewBuilder
    private func avatarCell(for user: SharedModels.User) -> some View {
        HStack(spacing: 12) {
            self.userAvatar(for: user)
                .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 5) {
                Text(user.fullName ?? "No username provided")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(user.email ?? "No email registered")
                    .font(.system(size: 14, weight: .regular))
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
    SettingsAccountView(store: Store(initialState: SettingsAccount.State(user: .mock)) {
        SettingsAccount()
    })
}
