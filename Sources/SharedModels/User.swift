import Foundation

public struct SignupRequest: Codable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct SignupResponse: Codable, Sendable {
    public let accessToken: String
    public let user: User

    public init(accessToken: String, user: User) {
        self.accessToken = accessToken
        self.user = user
    }
}

public extension SignupResponse {
    static var mock: Self {
        .init(accessToken: "accessToken", user: .mock)
    }
}

public struct LoginRequest: Codable, Sendable {
    public let idToken: String

    public init(idToken: String) {
        self.idToken = idToken
    }
}

public struct LoginResponse: Codable, Sendable {
    public let accessToken: String
    public let user: User

    public init(accessToken: String, user: User) {
        self.accessToken = accessToken
        self.user = user
    }
}

public extension LoginResponse {
    static var mock: Self {
        .init(accessToken: "accessToken", user: .mock)
    }
}

public struct User: Codable, Sendable, Equatable {
    public let id: String
    public let email: String?
    public let fullName: String?
    public let photoURL: URL?

    public init(
        id: String,
        email: String? = nil,
        fullName: String? = nil,
        photoURL: URL? = nil
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.photoURL = photoURL
    }
}

public extension User {
    static var mock: Self {
        .init(id: "id")
    }
}
