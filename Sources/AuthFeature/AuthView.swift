import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: AuthFeature.self)
public struct AuthView: View {
    @Bindable public var store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                HStack(spacing: 0) {
                    Image(.appLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 50)
                    Text("EventBook")
                        .font(.system(size: 20))
                        .bold()
                }

                Text(self.store.authType.title)
                    .font(.system(size: 36))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 14) {
                    TextField("Email", text: self.$store.email)
                        .textFieldStyle(.auth)
                        .textContentType(.emailAddress)

                    PasswordField("Password", text: self.$store.password)
                        .textFieldStyle(.auth)
                        .textContentType(.password)

                    if self.store.authType == .signUp {
                        PasswordField("Confirm password", text: self.$store.confirmPassword)
                            .textFieldStyle(.auth)
                            .textContentType(.password)
                    }
                }

                Button {
                    if self.store.authType == .signIn {
                        send(.loginButtonTapped)
                    } else {
                        send(.signupButtonTapped)
                    }
                } label: {
                    Text(self.store.authType.title)
                }
                .buttonStyle(.primary(size: .fullWidth))
                .disabled(!self.store.isFormValid || self.store.isLoading)

                HStack(spacing: 5) {
                    Group {
                        Text(self.store.authType == .signIn ? "Don't have an account?" : "Already have an account?")
                        Text(self.store.authType == .signIn ? "Sign up" : "Log in")
                            .foregroundStyle(Color.purple400)
                            .onTapGesture {
                                send(.toggleButtonTapped)
                            }
                    }
                    .font(.labelLarge)
                }

                HStack(spacing: 8) {
                    VStack { Divider() }

                    Text("or continue with")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.neutral500)

                    VStack { Divider() }
                }

                VStack(spacing: 16) {
                    ProviderButton(of: .google) {
                        send(.providerButtonTapped(.google))
                    }

                    ProviderButton(of: .facebook) {
                        send(.providerButtonTapped(.facebook))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(30)
        .isLoading(self.store.isLoading)
        .alert(self.$store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}
