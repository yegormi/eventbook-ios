import APIClient
import Dependencies
import Foundation
import Helpers
import OpenAPIRuntime
import OpenAPIURLSession
import SharedModels
import XCTestDynamicOverlay

private func throwingUnderlyingError<T>(_ closure: () async throws -> T) async throws -> T {
    do {
        return try await closure()
    } catch let error as ClientError {
        throw error.underlyingError
    }
}

extension APIClient: DependencyKey {
    public static var liveValue: Self {
        let client = Client(
            serverURL: try! Servers.Server1.url(), // swiftlint:disable:this force_try
            configuration: Configuration(
                dateTranscoder: .iso8601WithFractions
            ),
            transport: URLSessionTransport(),
            middlewares: [
                ErrorMiddleware(),
                AuthenticationMiddleware(),
            ]
        )

        return Self(
            signup: { @Sendable request in
                try await throwingUnderlyingError {
                    try await client.createUserAccount(body: .json(request.toAPI())).created.body.json.toDomain()
                }
            },
            login: { @Sendable request in
                try await throwingUnderlyingError {
                    try await client.authenticateUser(body: .json(request.toAPI())).created.body.json.toDomain()
                }
            },
            getCurrentUser: {
                try await throwingUnderlyingError {
                    try await client.getCurrentUser().ok.body.json.toDomain()
                }
            }
        )
    }
}
