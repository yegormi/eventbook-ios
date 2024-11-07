import FirebaseAuth
import FirebaseCore
import Foundation
import SharedModels

extension FirebaseAuth.AuthDataResult {
    func toUser() throws -> SharedModels.User {
        try User(
            id: self.user.uid,
            email: self.additionalUserInfo?.profile?["email"] as? String,
            fullName: self.user.displayName,
            photoURL: self.user.photoURL
        )
    }
}
