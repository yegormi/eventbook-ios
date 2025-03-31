import ComposableArchitecture
import CoreLocation
import EventDetailsFeature
import Foundation
import MapKit
import SharedModels
import Styleguide
import SwiftHelpers
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Explore.self)
public struct ExploreView: View {
    @Bindable public var store: StoreOf<Explore>

    public init(store: StoreOf<Explore>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if self.store.isLocationEnabled {
                self.mapView
            } else {
                self.locationPermissionView
            }
        }
        .task { await send(.onTask).finish() }
        .onFirstAppear { send(.onFirstAppear) }
        .navigationDestination(
            item: self.$store.scope(
                state: \.destination?.eventDetails,
                action: \.destination.eventDetails
            )
        ) { store in
            EventDetailsView(store: store)
        }
        .sheet(
            item: self.$store.scope(
                state: \.destination?.eventPreview,
                action: \.destination.eventPreview
            )
        ) { store in
            NavigationStack {
                EventPreviewView(store: store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
        }
        .alert(
            self.$store.scope(
                state: \.destination?.alert,
                action: \.destination.alert
            )
        )
    }

    // MARK: - Location Permission View

    private var locationPermissionView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.neutral400)
                    .padding(.bottom, 8)

                Text("Enable location sharing")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.primary)

                Text("To see events near you, please enable location access.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.neutral500)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button("Go to Settings") {
                send(.settingsButtonTapped)
            }
            .buttonStyle(.primary(size: .small))
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // MARK: - Map View

    private var mapView: some View {
        ZStack(alignment: .bottom) {
            if let mapRegion = store.mapRegion {
                Group {
                    if #available(iOS 17.0, *) {
                        // iOS 17+ Map implementation
                        modernMapView(region: mapRegion)
                    } else {
                        // iOS 16 and earlier Map implementation
                        self.legacyMapView(region: mapRegion)
                    }
                }
            } else {
                // Placeholder while waiting for location
                Color(.systemBackground)
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
            }

            // Event cards at the bottom
            if !self.store.nearbyEvents.isEmpty {
                self.eventCardsPanel
            }
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 0) {
                if let address = store.currentAddress {
                    Text(address)
                        .font(.system(size: 14, weight: .medium))
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.opacity)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        send(.recenterMap, animation: .smooth)
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.accentColor)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }

                    Button {
                        send(.refreshButtonTapped)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.accentColor)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding()
        }
        .overlay(alignment: .center) {
            if self.store.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemBackground).opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
            }
        }
    }

    @available(iOS 17.0, *)
    private func modernMapView(region _: Explore.State.MapRegion) -> some View {
        Map(position: self.$store.cameraPosition) {
            // User's location marker
            if let location = store.currentLocation {
                Marker("Your location", coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                ))
                .tint(.blue)
            }

            // Event markers
            ForEach(self.store.nearbyEvents) { event in
                Annotation(
                    event.name,
                    coordinate: CLLocationCoordinate2D(latitude: event.lat, longitude: event.lng),
                    anchor: .bottom
                ) {
                    EventMarker(
                        event: event,
                        isSelected: event.id == self.store.selectedEvent?.id
                    )
                    .onTapGesture {
                        send(.eventAnnotationTapped(event), animation: .smooth)
                    }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        // Track changes from user interaction
        .onMapCameraChange { context in
            send(.regionChanged(
                context.camera.centerCoordinate,
                context.region.span.latitudeDelta,
                context.region.span.longitudeDelta
            ))
        }
    }

    private func legacyMapView(region: Explore.State.MapRegion) -> some View {
        let binding = Binding<MKCoordinateRegion>(
            get: {
                MKCoordinateRegion(
                    center: region.center,
                    span: MKCoordinateSpan(
                        latitudeDelta: region.span.latitudeDelta,
                        longitudeDelta: region.span.longitudeDelta
                    )
                )
            },
            set: { newRegion in
                send(.regionChanged(
                    newRegion.center,
                    newRegion.span.latitudeDelta,
                    newRegion.span.longitudeDelta
                ))
            }
        )

        return Map(
            coordinateRegion: binding,
            showsUserLocation: self.store.currentLocation != nil,
            annotationItems: self.store.nearbyEvents
        ) { event in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: event.lat, longitude: event.lng)) {
                EventMarker(
                    event: event,
                    isSelected: event.id == self.store.selectedEvent?.id
                )
                .onTapGesture {
                    send(.eventAnnotationTapped(event), animation: .smooth)
                }
            }
        }
    }

    // MARK: - Event Cards Panel

    private var eventCardsPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(self.store.nearbyEvents) { event in
                    EventCard(
                        event: event,
                        isSelected: event.id == self.store.selectedEvent?.id
                    ) {
                        send(.eventAnnotationTapped(event), animation: .smooth)
                    }
                    .frame(width: 240, height: 120)
                }
            }
        }
        .frame(height: 150)
    }
}

// MARK: - Supporting Views

struct EventMarker: View {
    let event: Event
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Category icon in a circle
            ZStack {
                Circle()
                    .fill(self.isSelected ? Color.accentColor : Color.secondary)
                    .frame(width: 34, height: 34)
                    .shadow(
                        color: self.isSelected ? Color.accentColor.opacity(0.5) : Color.black.opacity(0.2),
                        radius: self.isSelected ? 5 : 2
                    )

                if let category = event.categories.first {
                    Image(systemName: category.icon.sfSymbolName)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }

            // Pin shape
            Image(systemName: "triangle.fill")
                .font(.system(size: 12))
                .foregroundColor(self.isSelected ? Color.accentColor : Color.secondary)
                .rotationEffect(.degrees(180))
                .offset(y: -4)
        }
        .scaleEffect(self.isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: self.isSelected)
    }
}

struct EventCard: View {
    let event: Event
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: self.onTap) {
            CardContainer {
                VStack(alignment: .leading, spacing: 8) {
                    // Event name
                    Text(self.event.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    // Event date and location
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        Text(self.event.date.formatted(date: .numeric, time: .shortened))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                    Text(self.event.address)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    Spacer()

                    // Price and category
                    HStack {
                        // Price
                        Text("\(Int(self.event.price)) UAH")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)

                        Spacer()

                        // Category tag
                        if let category = event.categories.first {
                            HStack(spacing: 4) {
                                Image(systemName: category.icon.sfSymbolName)
                                    .font(.system(size: 10))

                                Text(category.name)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(self.isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
