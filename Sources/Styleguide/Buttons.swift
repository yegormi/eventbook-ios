import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    public enum Size {
        case small
        case fullWidth
        
        var verticalPadding: CGFloat {
            return 14
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: 32
            case .fullWidth: 0
            }
        }
    }
    
    @Environment(\.isEnabled) var isEnabled
    let size: Size
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(maxWidth: size == .fullWidth ? .infinity : nil)
            .font(.titleMedium)
            .foregroundStyle(Color.white)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 100)
                    .fill(isEnabled ? Color.blue : Color.blue.opacity(0.2))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.1 : 0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static func primary(size: PrimaryButtonStyle.Size) -> PrimaryButtonStyle {
        .init(size: size)
    }
    
    /// Default primary button style (dynamic)
    public static var primary: PrimaryButtonStyle { .primary(size: .small) }
}
