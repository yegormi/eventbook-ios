import Dependencies
import DependenciesMacros
import Foundation
import SharedModels
import Supabase
import XCTestDynamicOverlay

@DependencyClient
public struct SupabaseSwiftClient: Sendable {
    public var signInWithIdToken: @Sendable (_ credentials: OpenIDConnectCredentials) async throws -> Session
    public var signIn: @Sendable (_ email: String, _ password: String) async throws -> Session
    public var signUp: @Sendable (_ email: String, _ password: String) async throws -> Session
    public var signOut: @Sendable () async throws -> Void
    public var handle: @Sendable (_ url: URL) -> Bool = { _ in false }
}

public extension SupabaseSwiftClient {
    static let mock = SupabaseSwiftClient(
        signInWithIdToken: { _ in unimplemented("\(Self.self).signInWithIdToken", placeholder: .mock) },
        signIn: { _, _ in unimplemented("\(Self.self).signIn", placeholder: .mock) },
        signUp: { _, _ in unimplemented("\(Self.self).signUp", placeholder: .mock) },
        signOut: { unimplemented("\(Self.self).signOut") },
        handle: { _ in unimplemented("\(Self.self).handle", placeholder: false) }
    )
}

extension SupabaseSwiftClient: TestDependencyKey {
    public static let previewValue = SupabaseSwiftClient.mock
    public static let testValue = SupabaseSwiftClient()
}

public extension DependencyValues {
    var supabaseClient: SupabaseSwiftClient {
        get { self[SupabaseSwiftClient.self] }
        set { self[SupabaseSwiftClient.self] = newValue }
    }
}

extension Supabase.Session {
    static let mock = Supabase.Session(
        accessToken: "",
        tokenType: "",
        expiresIn: .zero,
        expiresAt: .zero,
        refreshToken: "",
        user: .mock
    )
}

extension Supabase.User {
    static let mock = Supabase.User(
        id: UUID(),
        appMetadata: [:],
        userMetadata: [:],
        aud: "",
        createdAt: Date(),
        updatedAt: Date()
    )
}
