import Foundation
import Tagged

public enum KeychainKeyTag {}
public typealias KeychainKey = Tagged<KeychainKeyTag, String>

public extension KeychainKey {
    static let appAuthenticationToken: Self = .init("APP_AUTHENTICATION_TOKEN")
}
