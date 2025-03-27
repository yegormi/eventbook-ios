import Foundation
import SharedModels

public struct AutocompleteEventResponse: Sendable {
    public let name: String
    public let description: String
    public let categories: [EventCategory]

    public init(
        name: String,
        description: String,
        categories: [EventCategory]
    ) {
        self.name = name
        self.description = description
        self.categories = categories
    }
}

public extension AutocompleteEventResponse {
    static let mock = Self(
        name: "Mock Event Name",
        description: "Mock Event Description",
        categories: [.mock]
    )
}
