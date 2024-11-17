import SwiftUI

public struct TabButtonStyle: ButtonStyle {
    public struct ColorScheme {
        let activeBackground: Color
        let inactiveBackground: Color
        let activeText: Color
        let inactiveText: Color

        public static var light: ColorScheme {
            ColorScheme(
                activeBackground: .purple400,
                inactiveBackground: .neutral100,
                activeText: .neutral0,
                inactiveText: .neutral600
            )
        }

        public static var dark: ColorScheme {
            ColorScheme(
                activeBackground: .purple400,
                inactiveBackground: .neutral800,
                activeText: .neutral0,
                inactiveText: .neutral300
            )
        }
    }

    public enum Size {
        case small
        case fullWidth

        var verticalPadding: CGFloat {
            switch self {
            case .small: 8
            case .fullWidth: 12
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: 23
            case .fullWidth: 0
            }
        }
    }

    @Environment(\.colorScheme) private var systemColorScheme

    let isActive: Bool
    let size: Size

    public init(
        isActive: Bool,
        size: Size
    ) {
        self.isActive = isActive
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        let colorScheme: ColorScheme = self.systemColorScheme == .dark ? .dark : .light

        configuration
            .label
            .frame(maxWidth: self.size == .fullWidth ? .infinity : nil)
            .font(.headlineSmall)
            .foregroundStyle(self.isActive ? colorScheme.activeText : colorScheme.inactiveText)
            .padding(.vertical, self.size.verticalPadding)
            .padding(.horizontal, self.size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(self.isActive ? colorScheme.activeBackground : colorScheme.inactiveBackground)
            )
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.1 : 0)
    }
}

public extension ButtonStyle where Self == TabButtonStyle {
    static func tabButton(
        isActive: Bool,
        size: TabButtonStyle.Size
    ) -> TabButtonStyle {
        .init(isActive: isActive, size: size)
    }

    static var tabButton: TabButtonStyle {
        .tabButton(isActive: true, size: .small)
    }
}
