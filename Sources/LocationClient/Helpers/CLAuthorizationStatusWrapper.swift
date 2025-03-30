import CoreLocation
import Foundation

public enum CLAuthorizationStatusWrapper: String, Sendable, CustomStringConvertible {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse

    init(_ clAuthorizationStatus: CLAuthorizationStatus) {
        switch clAuthorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .restricted:
            self = .restricted
        case .denied:
            self = .denied
        case .authorizedAlways:
            self = .authorizedAlways
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        @unknown default:
            self = .notDetermined
        }
    }

    public var description: String {
        self.rawValue
    }
}
