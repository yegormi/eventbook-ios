import SwiftUI

/// A secure text field component that allows toggling password visibility.
/// This field automatically handles focus states and scene phase changes.
public struct PasswordField: View {
    /// The label displayed as placeholder text in the field
    public let label: LocalizedStringKey

    /// Binding to the text value of the field
    @Binding public var text: String

    /// Controls whether the password text is visible
    @State private var showText = false

    /// Manages the focus state of the text fields
    @FocusState private var focus: Focus?

    /// The current scene phase, used to handle application state changes
    @Environment(\.scenePhase) private var scenePhase

    /// Creates a new password field with the specified label and text binding
    /// - Parameters:
    ///   - label: The localized string key to use as the field's label
    ///   - text: A binding to the text value of the field
    public init(_ label: LocalizedStringKey, text: Binding<String>) {
        self.label = label
        self._text = text
    }

    public var body: some View {
        ZStack {
            SecureField(self.label, text: self.$text)
                .focused(self.$focus, equals: .secure)
                .opacity(self.showText ? 0 : 1)

            TextField(self.label, text: self.$text)
                .focused(self.$focus, equals: .text)
                .opacity(self.showText ? 1 : 0)
        }
        .overlay(alignment: .trailing) {
            Button {
                self.showText.toggle()
            } label: {
                Image(systemName: self.showText ? "eye.slash.fill" : "eye.fill")
                    .frame(width: 50, height: 50)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accentColor(.secondary)
        }
        .onChange(of: self.focus) { _, new in
            if new != nil {
                self.focus = self.showText ? .text : .secure
            }
        }
        .onChange(of: self.scenePhase) { _, new in
            if new != .active {
                self.showText = false
            }
        }
        .onChange(of: self.showText) { _, new in
            if self.focus != nil {
                self.focus = new ? .text : .secure
            }
        }
    }
}

extension PasswordField {
    /// Focus states for the password field
    private enum Focus {
        /// The secure text field is focused
        case secure
        /// The plain text field is focused
        case text
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PasswordField("Password", text: .constant("Lorem Ipsum"))
        .padding()
}
