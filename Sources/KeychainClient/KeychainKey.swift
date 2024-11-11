import Foundation
import Tagged

public enum KeychainKeyTag {}
public typealias KeychainKey = Tagged<KeychainKeyTag, String>

public extension KeychainKey {
    static let appAccessToken: Self = .init("APP_ACCESS_TOKEN")
}
