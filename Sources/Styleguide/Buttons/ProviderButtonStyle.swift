import SwiftUI

public struct ProviderButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.colorScheme) var colorScheme

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .font(.system(size: 17))
            .frame(maxWidth: .infinity)
            .foregroundStyle(
                self.isEnabled ?
                    (self.colorScheme == .dark ? Color.neutral200 : Color.neutral50) :
                    (self.colorScheme == .dark ? Color.neutral600 : Color.neutral500)
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .fill(self.isEnabled ? Color.textFieldBackground : Color.neutral500)
                    .shadow(radius: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
    }
}

public extension ButtonStyle where Self == ProviderButtonStyle {
    static var provider: ProviderButtonStyle { .init() }
}
