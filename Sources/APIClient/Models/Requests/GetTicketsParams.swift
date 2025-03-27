import Foundation

public struct GetTicketsParams: Sendable {
    public let query: String?
    public let limit: Int
    public let page: Int

    public init(
        query: String? = nil,
        limit: Int,
        page: Int
    ) {
        self.query = query
        self.limit = limit
        self.page = page
    }
}
