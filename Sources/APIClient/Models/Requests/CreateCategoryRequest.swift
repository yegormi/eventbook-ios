import Foundation
import SharedModels

public struct CreateCategoryRequest: Sendable {
    public let name: String
    public let slug: String
    public let icon: CategoryIcon
    public let description: String

    public init(
        name: String,
        slug: String,
        icon: CategoryIcon,
        description: String
    ) {
        self.name = name
        self.slug = slug
        self.icon = icon
        self.description = description
    }
}
