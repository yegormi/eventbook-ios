import Dependencies
import DependenciesMacros
import Foundation
import GoogleClient
import GoogleSignIn
import Helpers
import UIKit

private enum GoogleAuthError: Error {
    case tokenUnavailable
}

extension GoogleClient: DependencyKey {
    public static let liveValue = GoogleClient(
        authenticate: {
            let rootViewController = try UIViewController.getRootViewController()
            let scopes = [
                "https://www.googleapis.com/auth/profile.emails.read",
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/userinfo.profile",
            ]
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController,
                hint: nil,
                additionalScopes: scopes
            )
            return try result.user.toDomain()
        },
        restorePreviousSignIn: {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            return try user.toDomain()
        },
        signOut: {
            try await GIDSignIn.sharedInstance.disconnect()
        }
    )
}
