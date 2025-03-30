import Combine
import CoreLocation
import Dependencies
import DependenciesMacros
import Foundation

extension LocationClient: DependencyKey {
    public static var liveValue: LocationClient {
        let manager = LocationManager()
        return LocationClient { type in
            manager.requestAuthorization(type)
        } checkAuthorizationStatus: {
            await manager.checkAuthorizationStatus()
        } didChangeAuthorizationStatus: {
            manager.didChangeAuthorizationStatus()
        } start: {
            manager.startUpdatingLocation()
        } stop: {
            manager.stopUpdatingLocation()
        } requestCurrentLocation: {
            try await manager.requestLocation()
        }
    }
}

extension LocationClient {
    final class Delegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
        private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?
        private var locationContinuation: AsyncStream<CLLocation>.Continuation?
        private var errorContinuation: AsyncStream<Error>.Continuation?

        private var activeAuthorizationStream: AsyncStream<CLAuthorizationStatus>?
        private var activeLocationStream: AsyncStream<CLLocation>?
        private var activeErrorStream: AsyncStream<Error>?

        override init() {
            super.init()
            assert(Thread.isMainThread, "Delegate must be initialized on the main thread")
        }

        func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            self.authorizationContinuation?.yield(status)
        }

        func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            self.locationContinuation?.yield(location)
        }

        func locationManager(_: CLLocationManager, didFailWithError error: Error) {
            self.errorContinuation?.yield(error)
        }

        func createAuthorizationStream() -> AsyncStream<CLAuthorizationStatus> {
            let (stream, continuation) = AsyncStream.makeStream(of: CLAuthorizationStatus.self)
            self.authorizationContinuation = continuation
            self.activeAuthorizationStream = stream
            return stream
        }

        func createLocationStream() -> AsyncStream<CLLocation> {
            let (stream, continuation) = AsyncStream.makeStream(of: CLLocation.self)
            self.locationContinuation = continuation
            self.activeLocationStream = stream
            return stream
        }

        func createErrorStream() -> AsyncStream<Error> {
            let (stream, continuation) = AsyncStream.makeStream(of: Error.self)
            self.errorContinuation = continuation
            self.activeErrorStream = stream
            return stream
        }

        func cleanup() {
            self.authorizationContinuation?.finish()
            self.locationContinuation?.finish()
            self.errorContinuation?.finish()

            self.authorizationContinuation = nil
            self.locationContinuation = nil
            self.errorContinuation = nil

            self.activeAuthorizationStream = nil
            self.activeLocationStream = nil
            self.activeErrorStream = nil
        }
    }
}
