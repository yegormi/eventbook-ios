import FirebaseAuth
import FirebaseCore
import Foundation
import SharedModels

extension FirebaseAuth.User {
    func toDomain() throws -> SharedModels.User {
        try User(id: self.uid, email: self.email)
    }
}
