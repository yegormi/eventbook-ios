import Foundation

enum AuthType {
    case signIn, signUp

    var title: String {
        switch self {
        case .signIn:
            "Log in"
        case .signUp:
            "Sign up"
        }
    }

    mutating func toggle() {
        self = (self == .signIn) ? .signUp : .signIn
    }
}
