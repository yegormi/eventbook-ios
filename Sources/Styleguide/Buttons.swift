import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
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
                    (self.colorScheme == .dark ? Color.neutral200 : Color.neutral50) :
                    (self.colorScheme == .dark ? Color.gray : Color.neutral500)
            )
            .padding(.vertical, self.size.verticalPadding)
            .padding(.horizontal, self.size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        self.isEnabled ? Color.purple400 : (self.colorScheme == .dark ? Color.neutral600 : Color.neutral200)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.1 : 0)
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    static func primary(size: PrimaryButtonStyle.Size) -> PrimaryButtonStyle {
        .init(size: size)
    }

    /// Default primary button style (dynamic)
    static var primary: PrimaryButtonStyle { .primary(size: .small) }
}

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
    static var service: ProviderButtonStyle { .init() }
}

struct ButtonStylesPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                // Primary Button - Full Width
                Button("Primary Full Width") {}
                    .buttonStyle(.primary(size: .fullWidth))

                // Primary Button - Small
                Button("Primary Small") {}
                    .buttonStyle(.primary(size: .small))

                // Primary Button - Disabled
                Button("Primary Disabled") {}
                    .buttonStyle(.primary(size: .small))
                    .disabled(true)

                Divider().padding(.vertical, 20)

                // Service Button - Enabled
                Button("Service Button") {}
                    .buttonStyle(.service)

                // Service Button - Disabled
                Button("Service Disabled") {}
                    .buttonStyle(.service)
                    .disabled(true)
            }
            .padding()
            .preferredColorScheme(.light) // Light mode preview
            .previewDisplayName("Light Mode")

            VStack(spacing: 20) {
                // Primary Button - Full Width
                Button("Primary Full Width") {}
                    .buttonStyle(.primary(size: .fullWidth))

                // Primary Button - Small
                Button("Primary Small") {}
                    .buttonStyle(.primary(size: .small))

                // Primary Button - Disabled
                Button("Primary Disabled") {}
                    .buttonStyle(.primary(size: .small))
                    .disabled(true)

                Divider().padding(.vertical, 20)

                // Service Button - Enabled
                Button("Service Button") {}
                    .buttonStyle(.service)

                // Service Button - Disabled
                Button("Service Disabled") {}
                    .buttonStyle(.service)
                    .disabled(true)
            }
            .padding()
            .preferredColorScheme(.dark) // Dark mode preview
            .previewDisplayName("Dark Mode")
        }
    }
}
