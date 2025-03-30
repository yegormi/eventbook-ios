import CoreLocation
import Dependencies

extension CLLocation {
    static let mock = CLLocation(latitude: 37.7749, longitude: -122.4194)
}

public extension LocationClient {
    static let mock = LocationClient(
        requestAuthorization: { _ in },
        checkAuthorizationStatus: {
            CLAuthorizationStatusWrapper.authorizedWhenInUse
        },
        didChangeAuthorizationStatus: {
            AsyncStream { continuation in
                continuation.yield(.authorizedWhenInUse)
                continuation.finish()
            }
        },
        start: {
            AsyncStream { continuation in
                continuation.yield(CLLocationWrapper(.mock))
                continuation.finish()
            }
        },
        stop: {},
        requestCurrentLocation: {
            CLLocationWrapper(.mock)
        }
    )
}

extension LocationClient: TestDependencyKey {
    public static let previewValue = LocationClient.mock
    public static let testValue = LocationClient(
        requestAuthorization: unimplemented("LocationClient.requestAuthorization"),
        checkAuthorizationStatus: unimplemented("LocationClient.checkAuthorizationStatus"),
        didChangeAuthorizationStatus: unimplemented("LocationClient.didChangeAuthorizationStatus"),
        start: unimplemented("LocationClient.start"),
        stop: unimplemented("LocationClient.stop"),
        requestCurrentLocation: unimplemented("LocationClient.requestCurrentLocation")
    )
}
