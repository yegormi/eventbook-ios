import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI

@ViewAction(for: AuthFeature.self)
public struct AuthView: View {
    @Bindable public var store: StoreOf<AuthFeature>

    public init(store: StoreOf<AuthFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("🌟 EventBook")
                    .font(.system(size: 20))
                    .bold()

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
                    if self.store.isLoading {
                        ProgressView()
                    } else {
                        Text(self.store.authType.title)
                    }
                }
                .buttonStyle(.primary(size: .fullWidth))
                .disabled(!self.store.isFormValid || self.store.isLoading)

                HStack(spacing: 5) {
                    Group {
                        Text(self.store.authType == .signIn ? "Don't have an account?" : "Already have an account?")
                        Text(self.store.authType == .signIn ? "Sign up" : "Log in")
                            .foregroundStyle(Color.purple300)
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
                    ServiceButton(authService: .google) {
                        send(.loginButtonTapped)
                    }

                    ServiceButton(authService: .facebook) {
                        send(.loginButtonTapped)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(30)
        .alert(self.$store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}
