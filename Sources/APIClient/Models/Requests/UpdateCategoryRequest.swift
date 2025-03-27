import Foundation
import SharedModels

public struct UpdateCategoryRequest: Sendable {
    public let name: String?
    public let slug: String?
    public let icon: CategoryIcon?
    public let description: String?

    public init(
        name: String? = nil,
        slug: String? = nil,
        icon: CategoryIcon? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.slug = slug
        self.icon = icon
        self.description = description
    }
}
