import CoreLocation
import Foundation

extension LocationClient {
    final class LocationManager: @unchecked Sendable {
        private var manager: CLLocationManager!
        private var delegate: Delegate!
        private var isTracking = false
        private var isInitialized = false

        init() {
            self.setupOnMainThread()
        }

        private func setupOnMainThread() {
            if Thread.isMainThread {
                self.performSetup()
            } else {
                DispatchQueue.main.sync {
                    self.performSetup()
                }
            }
        }

        private func performSetup() {
            assert(Thread.isMainThread, "CLLocationManager must be initialized on main thread")

            self.manager = CLLocationManager()
            self.delegate = Delegate()
            self.manager.delegate = self.delegate

            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.distanceFilter = kCLDistanceFilterNone
            self.manager.pausesLocationUpdatesAutomatically = false

            self.isInitialized = true
        }

        func requestAuthorization(_ type: AuthorizationType) {
            guard self.isInitialized else { return }

            Task { @MainActor in
                switch type {
                case .whenInUse:
                    self.manager.requestWhenInUseAuthorization()
                case .always:
                    self.manager.requestAlwaysAuthorization()
                }
            }
        }

        func checkAuthorizationStatus() async -> CLAuthorizationStatusWrapper {
            guard self.isInitialized else { return .notDetermined }

            let status = Task { @MainActor in
                self.manager.authorizationStatus
            }
            return await CLAuthorizationStatusWrapper(Task.isCancelled ? .notDetermined : status.value)
        }

        func didChangeAuthorizationStatus() -> AsyncStream<CLAuthorizationStatusWrapper> {
            guard self.isInitialized else {
                return AsyncStream { continuation in
                    continuation.finish()
                }
            }

            return AsyncStream { continuation in
                let authStream = self.delegate.createAuthorizationStream()

                Task {
                    for await status in authStream {
                        continuation.yield(CLAuthorizationStatusWrapper(status))
                    }
                    continuation.finish()
                }
            }
        }

        func startUpdatingLocation() -> AsyncStream<CLLocationWrapper> {
            guard self.isInitialized, !self.isTracking else {
                return AsyncStream { continuation in
                    continuation.finish()
                }
            }

            self.isTracking = true

            Task { @MainActor in
                self.manager.startUpdatingLocation()
            }

            return AsyncStream { continuation in
                let locationStream = self.delegate.createLocationStream()
                let errorStream = self.delegate.createErrorStream()

                Task {
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            for await location in locationStream {
                                continuation.yield(CLLocationWrapper(location))
                            }
                        }

                        group.addTask {
                            for await error in errorStream {
                                print("Location error: \(error.localizedDescription)")
                            }
                        }
                    }

                    continuation.finish()
                }

                continuation.onTermination = { [weak self] _ in
                    Task { [weak self] in
                        self?.stopUpdatingLocation()
                    }
                }
            }
        }

        func stopUpdatingLocation() {
            guard self.isInitialized, self.isTracking else { return }

            self.isTracking = false
            Task { @MainActor in
                self.manager.stopUpdatingLocation()
                self.delegate.cleanup()
            }
        }

        func requestLocation() async throws -> CLLocationWrapper {
            guard self.isInitialized else {
                throw NSError(
                    domain: "LocationManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Location manager not initialized"]
                )
            }

            return try await withCheckedThrowingContinuation { continuation in
                let locationStream = self.delegate.createLocationStream()
                let errorStream = self.delegate.createErrorStream()

                Task {
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            guard let location = await locationStream.first(where: { _ in true }) else {
                                return
                            }
                            continuation.resume(returning: CLLocationWrapper(location))
                        }

                        group.addTask {
                            guard let error = await errorStream.first(where: { _ in true }) else {
                                return
                            }
                            continuation.resume(throwing: error)
                        }
                    }
                }

                Task { @MainActor in
                    self.manager.requestLocation()
                }
            }
        }
    }
}
