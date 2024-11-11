import CryptoKit
import Foundation

public func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)

    var randomBytes = [UInt8](repeating: 0, count: length)
    guard SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes) == errSecSuccess else {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed.")
    }

    let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    return String(randomBytes.map { charset[Int($0) % charset.count] })
}

public func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hash = SHA256.hash(data: inputData)
    return hash.map { String(format: "%02x", $0) }.joined()
}
