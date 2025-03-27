import Foundation

public struct AutocompleteEventRequest: Sendable {
    public let name: String?
    public let description: String?
    public let categories: [String]?

    public init(
        name: String? = nil,
        description: String? = nil,
        categories: [String]? = nil
    ) {
        self.name = name
        self.description = description
        self.categories = categories
    }
}
