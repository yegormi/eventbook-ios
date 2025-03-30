import Dependencies
import DependenciesMacros
import LocationClient

@DependencyClient
public struct GeocodeClient: Sendable {
    public var getAddress: @Sendable (CLLocationWrapper) async throws -> String
}

public extension DependencyValues {
    var geocodeClient: GeocodeClient {
        get { self[GeocodeClient.self] }
        set { self[GeocodeClient.self] = newValue }
    }
}
