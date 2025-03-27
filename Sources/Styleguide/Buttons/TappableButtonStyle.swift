import SwiftUI

public struct TappableButtonStyle: ButtonStyle {
    public init() {}

    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .opacity(self.isEnabled ? 1.0 : 0.3)
    }
}

public extension ButtonStyle where Self == TappableButtonStyle {
    /// Tappable button style - contains only animation and scale effect
    static var tappable: TappableButtonStyle { .init() }
}
