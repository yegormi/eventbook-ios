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
    static var mock: Self {
        User(id: "mock")
    }
}
