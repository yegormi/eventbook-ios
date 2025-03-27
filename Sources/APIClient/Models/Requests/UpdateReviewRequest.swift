import Foundation

public struct UpdateReviewRequest: Sendable {
    public let title: String?
    public let content: String?
    public let rating: Int?

    public init(
        title: String? = nil,
        content: String? = nil,
        rating: Int? = nil
    ) {
        self.title = title
        self.content = content
        self.rating = rating
    }
}
