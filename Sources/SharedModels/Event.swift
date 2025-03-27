import Foundation

public struct Event: Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let price: Double
    public let date: Date
    public let address: String
    public let lat: Double
    public let lng: Double
    public let author: User
    public let categories: [EventCategory]

    public init(
        id: String,
        name: String,
        description: String,
        price: Double,
        date: Date,
        address: String,
        lat: Double,
        lng: Double,
        author: User,
        categories: [EventCategory]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.date = date
        self.address = address
        self.lat = lat
        self.lng = lng
        self.author = author
        self.categories = categories
    }
}

public extension Event {
    static let mock = Self(
        id: "mock-event-id",
        name: "Mock Event",
        description: "This is a mock event",
        price: 9.99,
        date: Date(),
        address: "123 Mock Street",
        lat: 37.7749,
        lng: -122.4194,
        author: .mock,
        categories: [.mock]
    )
}

public extension PaginatedResponse where T == Event {
    static let mock = Self.mock(data: [.mock])
}
