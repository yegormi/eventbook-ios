import CoreLocation
import Foundation

public struct CLLocationWrapper: Equatable, Sendable {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
    public let altitude: CLLocationDistance
    public let accuracy: CLLocationAccuracy
    public let speed: CLLocationSpeed
    public let course: CLLocationDirection
    public let timestamp: Date

    init(_ clLocation: CLLocation) {
        self.latitude = clLocation.coordinate.latitude
        self.longitude = clLocation.coordinate.longitude
        self.altitude = clLocation.altitude
        self.accuracy = clLocation.horizontalAccuracy
        self.timestamp = clLocation.timestamp
        self.speed = clLocation.speed
        self.course = clLocation.course
    }
}
