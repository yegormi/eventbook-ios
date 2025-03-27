import Foundation

public struct UpdateEventRequest: Sendable {
    public let name: String?
    public let description: String?
    public let price: Double?
    public let date: Date?
    public let lat: Double?
    public let lng: Double?
    public let categories: [String] // Category slugs

    public init(
        name: String? = nil,
        description: String? = nil,
        price: Double? = nil,
        date: Date? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        categories: [String]
    ) {
        self.name = name
        self.description = description
        self.price = price
        self.date = date
        self.lat = lat
        self.lng = lng
        self.categories = categories
    }
}
