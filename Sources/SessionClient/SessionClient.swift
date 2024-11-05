import Dependencies
import DependenciesMacros
import SharedModels
import SwiftUI

@DependencyClient
public struct SessionClient: Sendable {
    public var authenticate: @Sendable (User) -> Void
    public var setCurrentAuthenticationToken: @Sendable (String) throws -> Void
    public var currentAuthenticationToken: @Sendable () throws -> String?
    public var currentUser: @Sendable () -> User?
    public var currentUsers: @Sendable () -> AsyncStream<User?> = { .never }
    public var logout: @Sendable () throws -> Void
}

public extension SessionClient {
    /// Provided non-optional access to `currentUser`. Will crash if user was nil
    var unsafeCurrentUser: User {
        self.currentUser()! // swiftlint:disable:this force_unwrapping
    }
}

public extension DependencyValues {
    var session: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
