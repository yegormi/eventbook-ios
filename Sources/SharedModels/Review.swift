import Foundation

public struct Review: Equatable, Identifiable, Sendable {
    public let id: String
    public let event: Event
    public let author: User
    public let title: String
    public let content: String
    public let rating: Int
    public let createdAt: Date

    public init(
        id: String,
        event: Event,
        author: User,
        title: String,
        content: String,
        rating: Int,
        createdAt: Date
    ) {
        self.id = id
        self.event = event
        self.author = author
        self.title = title
        self.content = content
        self.rating = rating
        self.createdAt = createdAt
    }
}

public extension Review {
    static let mock = Self(
        id: "mock-review-id",
        event: .mock,
        author: .mock,
        title: "Mock Review",
        content: "This is a mock review",
        rating: 5,
        createdAt: Date()
    )
}

public extension PaginatedResponse where T == Review {
    static let mock = Self.mock(data: [.mock])
}
