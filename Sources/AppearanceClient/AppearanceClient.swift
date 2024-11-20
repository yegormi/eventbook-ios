import Dependencies
import DependenciesAdditions
import DependenciesMacros
import SharedModels

@DependencyClient
public struct AppearanceClient: Sendable {
    public var setAppearance: @Sendable (PhoneAppearance) async -> Void
    public var currentAppearance: @Sendable () -> PhoneAppearance = { .system }
    public var configure: @Sendable () async -> Void
}

extension AppearanceClient: TestDependencyKey {
    public static let testValue = Self(
        setAppearance: unimplemented("\(Self.self).setAppearance"),
        currentAppearance: unimplemented("\(Self.self).currentAppearance", placeholder: .system),
        configure: unimplemented("\(Self.self).configure")
    )
}

public extension DependencyValues {
    var appearance: AppearanceClient {
        get { self[AppearanceClient.self] }
        set { self[AppearanceClient.self] = newValue }
    }
}
