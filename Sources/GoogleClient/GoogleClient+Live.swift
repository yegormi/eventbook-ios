import Dependencies
import DependenciesMacros
import Foundation
import GoogleSignIn
import Helpers
import UIKit

private enum GoogleAuthError: LocalizedError {
    case tokenUnavailable

    var errorDescription: String? {
        switch self {
        case .tokenUnavailable:
            "Token is currently unavailable. Please try again later."
        }
    }
}

extension GoogleClient: DependencyKey {
    public static let liveValue = GoogleClient(
        authenticate: { @MainActor in
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

extension GIDSignInResult: @unchecked Sendable {}
