//
//  File.swift
//  eventbook-ios
//
//  Created by Yehor Myropoltsev on 05.11.2024.
//

import Foundation
import APIClient

extension Components.Schemas.ErrorResponse {
    func toDomain() -> APIErrorPayload {
        .init(code: self.code.toDomain(), message: self.message)
    }
}

extension Components.Schemas.ErrorResponse.codePayload {
    func toDomain() -> APIErrorPayload.Code {
        switch self {
        case ._internal: return .internalError
        case .email_hyphen_not_hyphen_unique: return .emailNotUnique
        case .entity_hyphen_not_hyphen_found: return .entityNotFound
        case .expired_hyphen_access_hyphen_token: return .expiredAccessToken
        case .incorrect_hyphen_password: return .incorrectPassword
        case .invalid_hyphen_access_hyphen_token: return .invalidAccessToken
        case .no_hyphen_access_hyphen_token: return .noAccessToken
        }
    }
}
