import Foundation

public struct PaginatedResponse<T: Sendable>: Sendable {
    public let data: [T]
    public let total: Int
    public let limit: Int
    public let pagesCount: Int

    public init(
        data: [T],
        total: Int,
        limit: Int,
        pagesCount: Int
    ) {
        self.data = data
        self.total = total
        self.limit = limit
        self.pagesCount = pagesCount
    }
}

public extension PaginatedResponse {
    static func mock(data: [T]) -> Self {
        Self(
            data: data,
            total: data.count,
            limit: 10,
            pagesCount: 1
        )
    }
}
