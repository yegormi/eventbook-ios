import Foundation

public struct APIErrorPayload: Equatable, Sendable {
    public enum Code: Equatable, Sendable {
        case internalError
        case noAccessToken
        case invalidAccessToken
        case expiredAccessToken
        case entityNotFound
        case incorrectPassword
        case emailNotUnique
    }

    public let code: Code
    public let message: String

    public init(code: Code, message: String) {
        self.code = code
        self.message = message
    }
}

public enum APIError: LocalizedError, Equatable {
    case badStatusCodeWithNoBody(Int)
    case withPayload(APIErrorPayload)

    public var errorDescription: String? {
        switch self {
        case .badStatusCodeWithNoBody:
            "An unknown error occurred."
        case let .withPayload(payload):
            payload.message
        }
    }
}
