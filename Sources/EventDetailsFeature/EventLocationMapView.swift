import MapKit
import SwiftUI

// MARK: - Enhanced MapKit Integration

/// A more advanced map view with customizable annotation
struct EventLocationMapView: View {
    let coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    let onTap: () -> Void

    @State private var region: MKCoordinateRegion
    @State private var mapSelection: MKMapItem?

    init(coordinate: CLLocationCoordinate2D, name: String, address: String, onTap: @escaping () -> Void) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.onTap = onTap

        // Initialize region with the event location
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            // Use the new Map API in iOS 17
            advancedMapView
        } else {
            // Fallback for iOS 16 and earlier
            self.legacyMapView
        }
    }

    @available(iOS 17.0, *) private var advancedMapView: some View {
        Map {
            // Add annotation with callout
            Annotation(
                self.name,
                coordinate: self.coordinate,
                anchor: .bottom
            ) {
                ZStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white, .red)
                        .shadow(radius: 2)
                }
            }
            .annotationTitles(.visible)
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .overlay(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: self.onTap)
        )
    }

    // Legacy map implementation for iOS 16 and earlier
    private var legacyMapView: some View {
        Map(coordinateRegion: self.$region, annotationItems: [
            LocationPin(
                coordinate: self.coordinate,
                title: self.name
            ),
        ]) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                VStack(spacing: 0) {
                    Text(pin.title)
                        .font(.caption)
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(5)
                        .shadow(radius: 2)

                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .onTapGesture {
                    self.onTap()
                }
            }
        }
        .overlay(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: self.onTap)
        )
    }
}

// Helper struct for map annotation
struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

// MARK: - Map View Integration in EventDetailsView

extension EventDetailsView {
    var mapView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.system(size: 18, weight: .bold))

            // MapKit integration
            EventLocationMapView(
                coordinate: CLLocationCoordinate2D(
                    latitude: self.store.event.lat,
                    longitude: self.store.event.lng
                ),
                name: self.store.event.name,
                address: self.store.event.address
            ) {
                send(.showLocationButtonTapped)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            // Address below the map
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(Color.gray)

                Text(self.store.event.address)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)

                Spacer()

                Button("Get Directions") {
                    send(.showLocationButtonTapped)
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Preview

struct EventMapView_Previews: PreviewProvider {
    static var previews: some View {
        EventLocationMapView(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            name: "Sample Event",
            address: "123 Example Street, San Francisco"
        ) {}
            .frame(height: 300)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
