@preconcurrency import CoreLocation
import Dependencies
import DependenciesMacros
import Foundation
import OSLog

private let logger = Logger(subsystem: "GeocodeClient", category: "GeocodeClient+Live")

extension GeocodeClient: DependencyKey {
    public static var liveValue: GeocodeClient {
        let geocoder = CLGeocoder()

        return Self { location in
            do {
                let clLocation = CLLocation(
                    latitude: location.latitude,
                    longitude: location.longitude
                )

                let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
                guard let placemark = placemarks.first else {
                    logger.warning("No placemarks found for location")
                    throw GeocodingError.noResults
                }

                /// Create a readable address string
                let components = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                ].compactMap(\.self)

                let address = components.isEmpty ? "Unknown location" : components.joined(separator: " ")
                logger.debug("Successfully formatted address: \(address)")
                return address
            } catch let error as GeocodingError {
                logger.error("Geocoding error: \(error.localizedDescription)")
                throw error
            } catch {
                logger.error("Failed to reverse geocode location: \(error.localizedDescription)")
                throw GeocodingError.geocodingFailed(error)
            }
        }
    }
}

public enum GeocodingError: LocalizedError {
    case noResults
    case geocodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .noResults:
            "Could not determine address for location"
        case let .geocodingFailed(error):
            "Failed to geocode location: \(error.localizedDescription)"
        }
    }
}
