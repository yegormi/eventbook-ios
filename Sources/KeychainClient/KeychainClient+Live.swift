import Dependencies
import Foundation
import Security

extension KeychainClient: DependencyKey {
    public static var liveValue: Self {
        // swiftlint:disable:next force_unwrapping
        let serviceName = Bundle.main.bundleIdentifier!

        return Self(
            set: { key, data in
                let getQuery = [
                    kSecAttrAccount as String: key.rawValue,
                    kSecAttrService as String: serviceName,
                    kSecClass as String: kSecClassGenericPassword,
                ] as CFDictionary

                let getStatus = SecItemCopyMatching(getQuery, nil)
                switch getStatus {
                case errSecSuccess:
                    // Item exists, override it.
                    let status = SecItemUpdate(getQuery, [kSecValueData: data] as CFDictionary)
                    guard status == errSecSuccess else {
                        throw KeychainClientError.failedToSaveItem(status)
                    }
                case errSecItemNotFound:
                    // Item does not exist, create it.
                    let createQuery = [
                        kSecAttrAccount as String: key.rawValue,
                        kSecAttrService as String: serviceName,
                        kSecValueData as String: data,
                        kSecClass as String: kSecClassGenericPassword,
                    ] as CFDictionary

                    let status = SecItemAdd(createQuery, nil)
                    guard status == errSecSuccess else {
                        throw KeychainClientError.failedToSaveItem(status)
                    }
                default:
                    throw KeychainClientError.failedToSaveItem(getStatus)
                }
            },
            get: { key in
                let query = [
                    kSecAttrAccount as String: key.rawValue,
                    kSecClass as String: kSecClassGenericPassword,
                    kSecReturnData as String: true,
                    kSecAttrService as String: serviceName,
                    kSecMatchLimit as String: kSecMatchLimitOne,
                ] as CFDictionary

                var result: CFTypeRef?
                let status = SecItemCopyMatching(query, &result)
                switch status {
                case errSecSuccess:
                    guard let data = result as? Data else {
                        throw KeychainClientError.unexpectedError
                    }
                    return data
                case errSecItemNotFound:
                    return nil
                default:
                    throw KeychainClientError.failedToRetrieveItem(status)
                }
            },
            delete: { key in
                let query = [
                    kSecAttrAccount as String: key.rawValue,
                    kSecAttrService as String: serviceName,
                    kSecClass as String: kSecClassGenericPassword,
                ] as CFDictionary

                let status = SecItemDelete(query)
                guard status == errSecSuccess || status == errSecItemNotFound else {
                    throw KeychainClientError.failedToDeleteItem(status)
                }
            }
        )
    }
}

public enum KeychainClientError: Error {
    case failedToSaveItem(OSStatus)
    case failedToRetrieveItem(OSStatus)
    case failedToDeleteItem(OSStatus)
    case dataConversionError
    case unexpectedError
}
