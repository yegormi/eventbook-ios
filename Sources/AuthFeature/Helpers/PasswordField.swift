import SwiftUI

struct PasswordField: View {
    let label: LocalizedStringKey
    @Binding var text: String

    @State private var showText = false
    @FocusState private var focus: Focus?
    @Environment(\.scenePhase) private var scenePhase

    init(_ label: LocalizedStringKey, text: Binding<String>) {
        self.label = label
        self._text = text
    }

    var body: some View {
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
    private enum Focus {
        case secure, text
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordField("Password", text: .constant("Lorem Ipsum"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
