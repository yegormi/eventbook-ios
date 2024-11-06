import APIClient
import Foundation
import SharedModels

extension Components.Schemas.SignupResponse {
    func toDomain() -> SignupResponse {
        .init(accessToken: self.accessToken, user: self.user.toDomain())
    }
}

extension SignupRequest {
    func toAPI() -> Components.Schemas.SignupRequest {
        .init(email: self.email, password: self.password)
    }
}

extension Components.Schemas.LoginResponse {
    func toDomain() -> LoginResponse {
        .init(accessToken: self.accessToken, user: self.user.toDomain())
    }
}

extension LoginRequest {
    func toAPI() -> Components.Schemas.LoginRequest {
        .init(email: self.email, password: self.password)
    }
}

extension Components.Schemas.UserDTO {
    func toDomain() -> User {
        .init(id: self.id, email: self.email)
    }
}
