import Foundation

public struct CreateReviewRequest: Sendable {
    public let title: String
    public let content: String
    public let rating: Int

    public init(
        title: String,
        content: String,
        rating: Int
    ) {
        self.title = title
        self.content = content
        self.rating = rating
    }
}
