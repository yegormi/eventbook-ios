import Dependencies
import DependenciesMacros
import SharedModels
import SwiftUI
import XCTestDynamicOverlay

@DependencyClient
public struct APIClient: Sendable {
    public var getCurrentUser: @Sendable () async throws -> User
    public var updateCurrentUser: @Sendable (UpdateUserRequest) async throws -> Void
    public var deleteCurrentUser: @Sendable () async throws -> Void
}

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
