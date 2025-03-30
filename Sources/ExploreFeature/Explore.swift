@preconcurrency import _MapKit_SwiftUI
import APIClient
import ComposableArchitecture
import CoreLocation
import EventDetailsFeature
import Foundation
import GeocodeClient
import LocationClient
import OSLog
import SharedModels
import UIKit

private let logger = Logger(subsystem: "ExploreFeature", category: "Explore")

@Reducer
public struct Explore: Reducer, Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?

        var nearbyEvents = IdentifiedArrayOf<Event>()
        var isLoading = false
        var currentLocation: CLLocationWrapper?
        var currentAddress: String?
        var authorizationStatus: CLAuthorizationStatusWrapper = .notDetermined
        var isTrackingLocation = false
        var selectedEvent: Event?
        var mapRegion: MapRegion?
        var cameraPosition: MapCameraPosition = .automatic

        var isLocationEnabled: Bool {
            switch self.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                true
            default:
                false
            }
        }

        struct MapRegion: Equatable, Sendable {
            var center: CLLocationCoordinate2D
            var span: MapSpan

            static func == (lhs: MapRegion, rhs: MapRegion) -> Bool {
                lhs.center.latitude == rhs.center.latitude &&
                    lhs.center.longitude == rhs.center.longitude &&
                    lhs.span == rhs.span
            }
        }

        struct MapSpan: Equatable, Sendable {
            var latitudeDelta: Double
            var longitudeDelta: Double
        }

        public init() {}
    }

    public enum Action: ViewAction {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case `internal`(Internal)
        case view(View)

        public enum Delegate {}

        public enum Internal: Sendable {
            case nearbyEventsResponse(Result<[Event], Error>)
            case authorizationStatusUpdate(CLAuthorizationStatusWrapper)
            case locationUpdate(Result<CLLocationWrapper, Error>)
            case addressUpdate(Result<String, Error>)
            case startLocationTracking
            case stopLocationTracking
            case didBecomeActive
        }

        public enum View: BindableAction {
            case binding(BindingAction<Explore.State>)
            case onAppear
            case refreshButtonTapped
            case eventAnnotationTapped(Event)
            case recenterMap
            case regionChanged(CLLocationCoordinate2D, Double, Double)
            case settingsButtonTapped
        }
    }

    @Reducer(state: .equatable, .sendable)
    public enum Destination {
        case eventDetails(EventDetails)
        case eventPreview(EventPreview)
        case alert(AlertState<Never>)
    }

    @Dependency(\.apiClient) var api
    @Dependency(\.locationClient) var location
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.geocodeClient) var geocoder
    @Dependency(\.openURL) var openURL

    enum CancelID {
        case locationTracking
        case locationUpdate
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .destination(.presented(.eventDetails(.delegate(.backButtonTapped)))):
                state.selectedEvent = nil
                state.destination = nil
                return .none

            case .destination(.presented(.eventPreview(.delegate(.viewDetailsButtonTapped)))):
                if let selectedEvent = state.selectedEvent {
                    state.destination = .eventDetails(EventDetails.State(event: selectedEvent))
                }
                return .none

            case .destination(.presented(.eventPreview(.delegate(.dismissButtonTapped)))):
                state.selectedEvent = nil
                state.destination = nil
                return .none

            case .destination(.dismiss):
                state.selectedEvent = nil
                return .none

            case .destination:
                return .none

            case .internal(.didBecomeActive):
                return .run { send in
                    await send(.internal(.authorizationStatusUpdate(
                        self.requestLocationPermission()
                    )))
                }

            case let .internal(.nearbyEventsResponse(.success(events))):
                state.isLoading = false
                state.nearbyEvents = IdentifiedArrayOf(uniqueElements: events)
                return .none

            case let .internal(.nearbyEventsResponse(.failure(error))):
                state.isLoading = false
                logger.error("Failed to fetch nearby events: \(error)")

                state.destination = .alert(AlertState {
                    TextState("Error")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState("Failed to load nearby events: \(error.localizedDescription)")
                })

                return .none

            case let .internal(.authorizationStatusUpdate(status)):
                let previousStatus = state.authorizationStatus
                state.authorizationStatus = status

                // Log initial status information
                logger.debug("Processing authorization status update: Previous=\(previousStatus), New=\(status)")

                // Only proceed if the status has been changed
                guard previousStatus != status else {
                    logger.debug("Authorization status unchanged (\(status)), no action taken")
                    return .none
                }

                logger.info("Location authorization status changed: \(previousStatus) → \(status)")

                // Determine if location permissions are now authorized
                let isEnabled = (status == .authorizedAlways || status == .authorizedWhenInUse)

                // Handle case where permissions are not granted
                guard isEnabled else {
                    logger.debug("Location permissions denied, stopping tracking")
                    return .send(.internal(.stopLocationTracking))
                }

                // Location is authorized, start tracking
                logger.debug("Location permissions granted, starting tracking")
                return .send(.internal(.startLocationTracking))

            case let .internal(.locationUpdate(.success(location))):
                state.currentLocation = location
                logger.debug("Location updated: \(location.longitude), \(location.latitude)")

                // Update map region if first location or recenter is requested
                if state.mapRegion == nil {
                    state.mapRegion = State.MapRegion(
                        center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        span: State.MapSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }

                return .merge(
                    self.getNearbyEvents(for: location, in: &state),
                    .run { send in
                        await send(.internal(.addressUpdate(Result {
                            try await self.geocoder.getAddress(location)
                        })))
                    }
                )

            case let .internal(.locationUpdate(.failure(error))):
                logger.error("Location error occurred: \(error.localizedDescription)")
                state.destination = .alert(AlertState {
                    TextState("Location Error")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.localizedDescription)
                })
                return .none

            case let .internal(.addressUpdate(.success(address))):
                state.currentAddress = address
                return .none

            case let .internal(.addressUpdate(.failure(error))):
                logger.error("Address lookup failed: \(error.localizedDescription)")
                state.currentAddress = "Unknown location"
                return .none

            case .internal(.startLocationTracking):
                return self.beginLocationTracking(&state)

            case .internal(.stopLocationTracking):
                return self.endLocationTracking(&state)

            case .view(.binding):
                return .none

            case .view(.onAppear):
                // Check location authorization status
                return .run { send in
                    await send(.internal(.authorizationStatusUpdate(
                        self.requestLocationPermission()
                    )))
                }

            case .view(.refreshButtonTapped):
                guard let location = state.currentLocation else {
                    logger.warning("No location available to refresh events")
                    state.destination = .alert(AlertState {
                        TextState("Location Required")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("We need your location to show nearby events. Please enable location services and try again.")
                    })
                    return .none
                }

                state.nearbyEvents.removeAll()
                return self.getNearbyEvents(for: location, in: &state)

            case let .view(.eventAnnotationTapped(event)):
                state.selectedEvent = event
                state.cameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(
                    latitude: event.lat,
                    longitude: event.lng
                ), distance: 5000))
                state.destination = .eventPreview(EventPreview.State(event: event))
                return .none

            case .view(.recenterMap):
                // Reset the map to the user's current location
                if let location = state.currentLocation {
                    state.mapRegion = State.MapRegion(
                        center: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude
                        ),
                        span: State.MapSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    state.cameraPosition = .camera(.init(centerCoordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ), distance: 5000))

                    return self.getNearbyEvents(for: location, in: &state)
                }
                return .none

            case let .view(.regionChanged(center, latDelta, longDelta)):
                // Update the map region as the user navigates
                state.mapRegion = State.MapRegion(
                    center: center,
                    span: State.MapSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                )
                return .none

            case .view(.settingsButtonTapped):
                // Open settings to allow user to enable location
                return self.openSystemSettings()
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    // MARK: - Private Methods

    private func beginLocationTracking(_ state: inout State) -> Effect<Action> {
        guard !state.isTrackingLocation else {
            logger.warning("Location tracking already started")
            return .none
        }
        state.isTrackingLocation = true

        return .run { send in
            for await location in await self.location.start() {
                await send(.internal(.locationUpdate(.success(location))))

                // We only need to get the location periodically, not continuously
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            }
        }
        .cancellable(id: CancelID.locationTracking, cancelInFlight: true)
    }

    private func endLocationTracking(_ state: inout State) -> Effect<Action> {
        guard state.isTrackingLocation else {
            logger.warning("Location tracking already stopped")
            return .none
        }
        state.isTrackingLocation = false

        return .merge(
            .cancel(id: CancelID.locationTracking),
            .run { _ in await self.location.stop() }
        )
    }

    private func getNearbyEvents(for location: CLLocationWrapper, in state: inout State) -> Effect<Action> {
        guard !state.isLoading else { return .none }
        state.isLoading = true

        return .run { send in
            await send(.internal(.nearbyEventsResponse(Result {
                try await self.api.getNearbyEvents(
                    location.latitude,
                    location.longitude
                )
            })))
        }
    }

    private func requestLocationPermission() async -> CLAuthorizationStatusWrapper {
        let status = await self.location.checkAuthorizationStatus()
        guard status == .notDetermined else { return status }

        await self.location.requestAuthorization(type: .whenInUse)
        return await self.location.checkAuthorizationStatus()
    }

    private func openSystemSettings() -> Effect<Action> {
        .run { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            await self.openURL(settingsUrl)
        }
    }
}
