import Foundation

public struct EventCategory: Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let slug: String
    public let icon: CategoryIcon
    public let description: String

    public init(
        id: String,
        name: String,
        slug: String,
        icon: CategoryIcon,
        description: String
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.icon = icon
        self.description = description
    }
}

public extension EventCategory {
    static let mock = Self(
        id: "mock-category-id",
        name: "Mock Category",
        slug: "mock-category",
        icon: .party,
        description: "This is a mock category"
    )
}
