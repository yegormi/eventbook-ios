import APIClient
import Foundation
import SharedModels

extension Components.Schemas.UserDto {
    func toDomain() -> User {
        User(
            id: self.id,
            email: self.email,
            fullName: self.fullName,
            phoneNumber: self.phoneNumber?.isEmpty == true ? nil : self.phoneNumber,
            photoURL: self.avatar.flatMap(URL.init)
        )
    }
}
