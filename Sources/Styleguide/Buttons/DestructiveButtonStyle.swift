import SwiftUI

public struct DestructiveButtonStyle: ButtonStyle {
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

    public enum Variant {
        case filled
        case outlined
    }

    @Environment(\.isEnabled) var isEnabled
    @Environment(\.colorScheme) var colorScheme
    let size: Size
    let variant: Variant

    public init(size: Size = .small, variant: Variant = .filled) {
        self.size = size
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: self.size == .fullWidth ? .infinity : nil)
            .font(.titleRegular)
            .foregroundStyle(
                self.foregroundColor(isEnabled: self.isEnabled, colorScheme: self.colorScheme)
            )
            .padding(.vertical, self.size.verticalPadding)
            .padding(.horizontal, self.size.horizontalPadding)
            .background(
                self.backgroundView(isEnabled: self.isEnabled, colorScheme: self.colorScheme)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.1 : 0)
    }

    @ViewBuilder
    private func backgroundView(isEnabled: Bool, colorScheme: ColorScheme) -> some View {
        switch self.variant {
        case .filled:
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isEnabled ?
                        (colorScheme == .dark ? Color.red600 : Color.red500) :
                        (colorScheme == .dark ? Color.neutral600 : Color.neutral200)
                )
        case .outlined:
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isEnabled ?
                        (colorScheme == .dark ? Color.red600 : Color.red500) :
                        (colorScheme == .dark ? Color.neutral600 : Color.neutral500),
                    lineWidth: 2
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.neutral0)
                )
        }
    }

    private func foregroundColor(isEnabled: Bool, colorScheme: ColorScheme) -> Color {
        if !isEnabled {
            return colorScheme == .dark ? Color.neutral600 : Color.neutral500
        }

        switch self.variant {
        case .filled:
            return colorScheme == .dark ? Color.neutral200 : Color.neutral50
        case .outlined:
            return colorScheme == .dark ? Color.red600 : Color.red500
        }
    }
}

public extension ButtonStyle where Self == DestructiveButtonStyle {
    static func destructive(
        size: DestructiveButtonStyle.Size = .small,
        variant: DestructiveButtonStyle.Variant = .filled
    ) -> DestructiveButtonStyle {
        .init(size: size, variant: variant)
    }

    /// Default destructive button style (filled, small)
    static var destructive: DestructiveButtonStyle { .destructive() }
}
