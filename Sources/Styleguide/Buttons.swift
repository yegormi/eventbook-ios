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
            .font(.titleRegular)
            .foregroundStyle(Color.black)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.purplePrimary : Color.purplePrimary.opacity(0.4))
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


public struct ServiceButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .font(.system(size: 17))
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 1)
                    .fill(Color.textFieldBackground)
                    .shadow(radius: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
    }
}

extension ButtonStyle where Self == ServiceButtonStyle {
    public static var service: ServiceButtonStyle { .init() }
}
