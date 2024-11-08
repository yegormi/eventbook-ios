import Dependencies
import DependenciesMacros
import FacebookCore
@preconcurrency import FacebookLogin
import Foundation
import Helpers
import UIKit

private enum FacebookAuthError: Error {
    case canceled
    case noToken
}

extension FacebookAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .canceled:
            "The user canceled the sign-in flow."
        case .noToken:
            "Unable to retrieve authentication token. Please try again."
        }
    }
}

extension FacebookClient: DependencyKey {
    public static var liveValue: FacebookClient {
        let facebook = LoginManager()

        return FacebookClient(
            authenticate: {
                try await withCheckedThrowingContinuation { continuation in
                    Task { @MainActor in
                        do {
                            let rootViewController = try UIViewController.getRootViewController()

                            facebook.logIn(permissions: ["public_profile", "email"], from: rootViewController) { result, error in
                                if let error {
                                    // Pass the error to the continuation
                                    continuation.resume(throwing: error)
                                } else if let result, !result.isCancelled {
                                    // Login successful, return the token string
                                    if let idToken = result.token?.tokenString {
                                        continuation.resume(returning: idToken)
                                    } else {
                                        continuation.resume(throwing: FacebookAuthError.noToken)
                                    }
                                } else {
                                    // Login was canceled by the user
                                    continuation.resume(throwing: FacebookAuthError.canceled)
                                }
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            },
            restorePreviousSignIn: {
                ""
            },
            signOut: {
                // Sign out logic here
            }
        )
    }
}
