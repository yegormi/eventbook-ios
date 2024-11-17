import Styleguide
import SwiftUI

/// A custom text field style designed for authentication forms.
/// Provides consistent styling with background, shadow, and padding.
public struct AuthTextFieldStyle: TextFieldStyle {
    @Environment(\.isEnabled) private var isEnabled

    /// Creates a new authentication text field style
    public init() {}

    // swiftlint:disable:next identifier_name
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(maxHeight: 50)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .font(.system(size: 17))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .foregroundColor(self.isEnabled ? .primary : .secondary)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .fill(self.isEnabled ? Color.textFieldBackground : Color.textFieldBackground.opacity(0.6))
                    .shadow(radius: self.isEnabled ? 1 : 0)
            )
            .opacity(self.isEnabled ? 1.0 : 0.6)
    }
}

public extension TextFieldStyle where Self == AuthTextFieldStyle {
    /// A convenience accessor for the authentication text field style
    static var auth: AuthTextFieldStyle {
        .init()
    }
}

#Preview {
    VStack {
        TextField("Username", text: .constant(""))
            .textFieldStyle(.auth)

        TextField("Email", text: .constant(""))
            .textFieldStyle(.auth)
            .disabled(true)

        TextField("Password", text: .constant(""))
            .textFieldStyle(.auth)
    }
    .padding()
}
