import Foundation

public struct GetEventsParams: Sendable {
    public let query: String?
    public let page: Int?
    public let limit: Int?

    public init(
        query: String? = nil,
        page: Int? = nil,
        limit: Int? = nil
    ) {
        self.query = query
        self.page = page
        self.limit = limit
    }
}
