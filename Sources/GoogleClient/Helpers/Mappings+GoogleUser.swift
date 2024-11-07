import GoogleSignIn
import SharedModels

extension GIDGoogleUser {
    func toDomain() throws -> GoogleUser {
        try GoogleUser(idToken: self.idToken?.tokenString, accessToken: self.accessToken.tokenString)
    }
}
