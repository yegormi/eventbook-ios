import Foundation

public struct User: Codable, Sendable, Equatable {
    public let id: String
    public let email: String?
    public let fullName: String?
    public let phoneNumber: String?
    public let photoURL: URL?

    public init(
        id: String,
        email: String? = nil,
        fullName: String? = nil,
        phoneNumber: String? = nil,
        photoURL: URL? = nil
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
    }
}

public extension User {
    static let mock = Self(
        id: "mock-user-id",
        email: "user@example.com",
        fullName: "Mock User",
        phoneNumber: "+1234567890",
        photoURL: URL(string: "https://example.com/avatar.jpg")
    )
}
