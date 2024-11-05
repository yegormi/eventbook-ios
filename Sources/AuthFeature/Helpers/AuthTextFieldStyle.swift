import Styleguide
import SwiftUI

struct AuthTextFieldStyle: TextFieldStyle {
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(maxHeight: 50)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .font(.system(size: 17))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .fill(Color.textFieldBackground)
                    .shadow(radius: 1)
            )
    }
}

extension TextFieldStyle where Self == AuthTextFieldStyle {
    static var auth: AuthTextFieldStyle {
        .init()
    }
}
