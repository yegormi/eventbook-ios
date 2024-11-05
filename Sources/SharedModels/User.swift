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

extension SignupResponse {
    public static var mock: Self {
        .init(accessToken: "accessToken", user: .mock)
    }
}

public struct LoginRequest: Codable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
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

public struct User: Codable, Sendable {
    public let id: String
    public let email: String

    public init(id: String, email: String) {
        self.id = id
        self.email = email
    }
}

public extension User {
    static var mock: Self {
        .init(id: "id", email: "email")
    }
}
