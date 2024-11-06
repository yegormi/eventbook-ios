import Dependencies
import Foundation

public struct KeychainClient: Sendable {
    public var set: @Sendable (_ key: KeychainKey, _ value: Data) throws -> Void
    public var get: @Sendable (KeychainKey) throws -> Data?
    public var delete: @Sendable (KeychainKey) throws -> Void

    public func set(_ key: KeychainKey, to stringValue: String) throws {
        // swiftlint:disable:next force_unwrapping
        try self.set(key, stringValue.data(using: .utf8)!)
    }

    public func get(_ key: KeychainKey) throws -> String? {
        try self.get(key).flatMap {
            String(data: $0, encoding: .utf8)
        }
    }
}

public extension DependencyValues {
    var keychain: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}
