import APIClient
import Foundation
import SharedModels

extension Components.Schemas.SignupResponseDto {
    func toDomain() -> SignupResponse {
        .init(accessToken: self.accessToken, user: self.user.toDomain())
    }
}

extension SignupRequest {
    func toAPI() -> Components.Schemas.SignupRequestDto {
        .init(email: self.email, password: self.password)
    }
}

extension Components.Schemas.LoginResponseDto {
    func toDomain() -> LoginResponse {
        .init(accessToken: self.accessToken, user: self.user.toDomain())
    }
}

extension LoginRequest {
    func toAPI() -> Components.Schemas.LoginRequestDto {
        .init(idToken: self.idToken)
    }
}

extension Components.Schemas.UserDto {
    func toDomain() -> User {
        .init(id: self.id, email: self.email)
    }
}
