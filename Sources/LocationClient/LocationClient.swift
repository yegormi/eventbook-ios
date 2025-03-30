import CoreLocation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct LocationClient: Sendable {
    public var requestAuthorization: @Sendable (_ type: AuthorizationType) async -> Void
    public var checkAuthorizationStatus: @Sendable () async -> CLAuthorizationStatusWrapper = { .notDetermined }
    public var didChangeAuthorizationStatus: @Sendable () async -> AsyncStream<CLAuthorizationStatusWrapper> = { .never }
    public var start: @Sendable () async -> AsyncStream<CLLocationWrapper> = { .never }
    public var stop: @Sendable () async -> Void
    public var requestCurrentLocation: @Sendable () async throws -> CLLocationWrapper
}

public extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}
