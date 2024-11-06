import APIClient
import Foundation

extension Components.Schemas.ErrorResponse {
    func toDomain() -> APIErrorPayload {
        .init(code: self.code.toDomain(), message: self.message)
    }
}

extension Components.Schemas.ErrorResponse.codePayload {
    func toDomain() -> APIErrorPayload.Code {
        switch self {
        case ._internal: .internalError
        case .email_hyphen_not_hyphen_unique: .emailNotUnique
        case .entity_hyphen_not_hyphen_found: .entityNotFound
        case .expired_hyphen_access_hyphen_token: .expiredAccessToken
        case .incorrect_hyphen_password: .incorrectPassword
        case .invalid_hyphen_access_hyphen_token: .invalidAccessToken
        case .no_hyphen_access_hyphen_token: .noAccessToken
        }
    }
}
