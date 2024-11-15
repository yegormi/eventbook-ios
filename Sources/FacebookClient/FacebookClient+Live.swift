import Dependencies
import DependenciesMacros
import FacebookCore
@preconcurrency import FacebookLogin
import Foundation
import SwiftHelpers
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
            authenticate: { @MainActor hashedNonce in
                let rootViewController = try UIViewController.getRootViewController()
                let permissions: [String] = ["public_profile", "email"]

                let configurtion = LoginConfiguration(
                    permissions: permissions,
                    tracking: .enabled,
                    nonce: hashedNonce
                )

                try await facebook.logIn(viewController: rootViewController, configuration: configurtion)
                guard let token = AuthenticationToken.current?.tokenString else {
                    throw FacebookAuthError.noToken
                }

                return FBAuthenticationToken(rawValue: token)
            },
            signOut: {
                facebook.logOut()
            }
        )
    }
}

public extension LoginManager {
    /// Logs the user in with specified permissions or requests additional permissions.
    ///
    /// This method initiates the login process and requests the specified permissions from the user.
    /// The login screen is presented from the specified `UIViewController`, or from the top-most view controller if none is
    /// provided.
    ///
    /// - Parameters:
    ///   - permissions: An array of permission strings to request from the user during login, such as `"public_profile"` or
    /// `"email"`.
    ///   - viewController: The `UIViewController` from which the login screen should be presented. If `nil`, the top-most view
    /// controller will be used.
    ///
    /// - Throws: Throws an error if the login process fails or if the user cancels the login process.
    ///
    /// - Returns: A `LoginManagerLoginResult` object that provides information about the login result, including granted
    /// permissions and access token.
    ///
    /// - Note: This method is marked as `@MainActor` and should be called on the main thread.
    @MainActor
    @discardableResult
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

    /// Logs the user in with custom configuration options.
    ///
    /// This method initiates the login process, using a custom `LoginConfiguration` for additional setup options.
    /// The login screen is presented from the specified `UIViewController`, or from the top-most view controller if none is
    /// provided.
    ///
    /// - Parameters:
    ///   - viewController: The `UIViewController` from which to present the login screen. If `nil`, the top-most view controller
    /// will be used.
    ///   - configuration: A `LoginConfiguration` object to customize login settings, such as set of permissions, tracking mode
    /// and attaching nonce.
    ///
    /// - Throws: Throws an error if the login process fails or if the user cancels the login process.
    ///
    /// - Returns: An optional `AccessToken` object representing the access token granted by the login. If the login fails or is
    /// canceled, `nil` is returned.
    ///
    /// - Note: This method is marked as `@MainActor` and should be called on the main thread.
    @MainActor
    @discardableResult
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
