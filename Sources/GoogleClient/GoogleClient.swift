import Dependencies
import DependenciesMacros
import GoogleSignIn
import SharedModels

@DependencyClient
public struct GoogleClient: Sendable {
    public var authenticate: @Sendable () async throws -> GoogleUser
    public var restorePreviousSignIn: @Sendable () async throws -> GoogleUser
    public var signOut: @Sendable () async throws -> Void
}

public extension GoogleClient {
    static let mock = GoogleClient(
        authenticate: { .mock },
        restorePreviousSignIn: { .mock },
        signOut: {}
    )
}

extension GoogleClient: TestDependencyKey {
    public static let previewValue = GoogleClient.mock
    public static let testValue = GoogleClient()
}

public extension DependencyValues {
    var authGoogle: GoogleClient {
        get { self[GoogleClient.self] }
        set { self[GoogleClient.self] = newValue }
    }
}
