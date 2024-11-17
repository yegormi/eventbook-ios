import Foundation

public enum PhoneAppearance: String, CaseIterable, Sendable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    public var icon: String {
        switch self {
        case .light: "sun.max"
        case .system: "iphone"
        case .dark: "moon"
        }
    }
}
