import Foundation

private struct MissingIDTokenError: Error {}

public struct GoogleUser: Sendable, Equatable {
    public let idToken: String
    public let accessToken: String

    public init(idToken: String, accessToken: String) {
        self.idToken = idToken
        self.accessToken = accessToken
    }

    public init(idToken: String?, accessToken: String) throws {
        guard let idToken else { throw MissingIDTokenError() }
        self.idToken = idToken
        self.accessToken = accessToken
    }
}

public extension GoogleUser {
    static var mock: GoogleUser { .init(idToken: "", accessToken: "") }
}
