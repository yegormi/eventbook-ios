import Dependencies
import DependenciesMacros
import FacebookCore
@preconcurrency import FacebookLogin
import Foundation
import Helpers
import UIKit

public enum FacebookAuthError: Error {
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
                let rootViewController = try UIViewController.getRootViewController()
                let permissions: [String] = ["public_profile", "email"]

                let result = try await facebook.logIn(permissions: permissions, from: rootViewController)
                guard let token = result.token?.tokenString else {
                    throw FacebookAuthError.noToken
                }

                return token
            },
            signOut: {
                facebook.logOut()
            }
        )
    }
}

public extension LoginManager {
    /// This method starts the Facebook login flow, presenting it from the specified `viewController`.
    /// It returns a `LoginManagerLoginResult` if successful or throws an error if the login attempt fails.
    ///
    /// - Parameters:
    ///   - permissions: An array of permissions to request from the user during login, such as `"public_profile"` or `"email"`.
    ///   - viewController: The view controller from which to present the login screen. If no view controller is passed, the top
    /// most is used.
    ///
    /// - Returns: A `LoginManagerLoginResult` containing information about the login result, such as the granted permissions and
    /// access token.
    @MainActor
    func logIn(permissions: [String], from viewController: UIViewController?) async throws -> LoginManagerLoginResult {
        try await withCheckedThrowingContinuation { continuation in
            self.logIn(permissions: permissions, from: viewController) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result, !result.isCancelled {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: FacebookAuthError.canceled)
                }
            }
        }
    }
}

public extension LoginManager {
    @MainActor
    func logIn(viewController: UIViewController?, configuration: LoginConfiguration?) async throws -> AccessToken? {
        try await withCheckedThrowingContinuation { continuation in
            self.logIn(viewController: viewController, configuration: configuration) { result in
                switch result {
                case .cancelled:
                    continuation.resume(throwing: FacebookAuthError.canceled)
                case let .failed(error):
                    continuation.resume(throwing: error)
                case let .success(_, _, token):
                    continuation.resume(returning: token)
                }
            }
        }
    }
}

extension AccessToken: @unchecked Sendable {}
