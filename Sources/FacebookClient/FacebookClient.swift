import Dependencies
import DependenciesMacros
import SharedModels

@DependencyClient
public struct FacebookClient: Sendable {
    public var authenticate: @Sendable @MainActor () async throws -> String
    public var signOut: @Sendable () async throws -> Void
}

public extension FacebookClient {
    static let mock = FacebookClient(
        authenticate: { "accessToken" },
        signOut: {}
    )
}

extension FacebookClient: TestDependencyKey {
    public static let previewValue = FacebookClient.mock
    public static let testValue = FacebookClient()
}

public extension DependencyValues {
    var authFacebook: FacebookClient {
        get { self[FacebookClient.self] }
        set { self[FacebookClient.self] = newValue }
    }
}
