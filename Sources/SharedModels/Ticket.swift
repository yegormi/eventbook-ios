import Foundation

public struct Ticket: Equatable, Identifiable, Sendable {
    public let id: String
    public let event: Event
    public let owner: User
    public let createdAt: Date

    public init(
        id: String,
        event: Event,
        owner: User,
        createdAt: Date
    ) {
        self.id = id
        self.event = event
        self.owner = owner
        self.createdAt = createdAt
    }
}

public extension Ticket {
    static let mock = Self(
        id: "mock-ticket-id",
        event: .mock,
        owner: .mock,
        createdAt: Date()
    )
}

public extension PaginatedResponse where T == Ticket {
    static let mock = Self.mock(data: [.mock])
}
