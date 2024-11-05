import Dependencies
import Foundation
import XCTestDynamicOverlay

extension KeychainClient: TestDependencyKey {
    public static let previewValue: KeychainClient = .ephemeral

    public static let testValue: KeychainClient = Self(
        set: unimplemented("\(Self.self).set"),
        get: unimplemented("\(Self.self).get"),
        delete: unimplemented("\(Self.self).delete")
    )
}

public extension KeychainClient {
    static var ephemeral: Self {
        let storage = LockIsolated<[String: Data]>([:])

        return Self(
            set: { key, data in
                storage.withValue {
                    $0[key.rawValue] = data
                }
            },
            get: { key in
                storage.value[key.rawValue]
            },
            delete: { key in
                _ = storage.withValue {
                    $0.removeValue(forKey: key.rawValue)
                }
            }
        )
    }
}
