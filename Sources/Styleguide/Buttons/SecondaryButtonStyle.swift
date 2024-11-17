import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
    public enum Size {
        case small
        case fullWidth

        var verticalPadding: CGFloat {
            14
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: 32
            case .fullWidth: 0
            }
        }
    }

    @Environment(\.isEnabled) var isEnabled
    @Environment(\.colorScheme) var colorScheme
    let size: Size

    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: self.size == .fullWidth ? .infinity : nil)
            .font(.titleRegular)
            .foregroundStyle(
                self.isEnabled ?
                    (self.colorScheme == .dark ? Color.purple400 : Color.purple500) :
                    (self.colorScheme == .dark ? Color.neutral600 : Color.neutral500)
            )
            .padding(.vertical, self.size.verticalPadding)
            .padding(.horizontal, self.size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        self.isEnabled ?
                            (self.colorScheme == .dark ? Color.purple400 : Color.purple500) :
                            (self.colorScheme == .dark ? Color.neutral600 : Color.neutral500),
                        lineWidth: 2
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(self.colorScheme == .dark ? Color.black.opacity(0.6) : Color.neutral0)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.1 : 0)
    }
}

public extension ButtonStyle where Self == SecondaryButtonStyle {
    static func secondary(size: SecondaryButtonStyle.Size) -> SecondaryButtonStyle {
        .init(size: size)
    }

    /// Default secondary button style (dynamic)
    static var secondary: SecondaryButtonStyle { .secondary(size: .small) }
}
