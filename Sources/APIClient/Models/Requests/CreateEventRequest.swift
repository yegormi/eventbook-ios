import Foundation

public struct CreateEventRequest: Sendable {
    public let name: String
    public let description: String
    public let price: Double
    public let date: Date
    public let address: String
    public let lat: Double
    public let lng: Double
    public let categories: [String] // Category slugs

    public init(
        name: String,
        description: String,
        price: Double,
        date: Date,
        address: String,
        lat: Double,
        lng: Double,
        categories: [String]
    ) {
        self.name = name
        self.description = description
        self.price = price
        self.date = date
        self.address = address
        self.lat = lat
        self.lng = lng
        self.categories = categories
    }
}
