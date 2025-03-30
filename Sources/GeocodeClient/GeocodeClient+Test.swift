import Dependencies

public extension GeocodeClient {
    static let mock = GeocodeClient { _ in "22 Lake Street" }
}

extension GeocodeClient: TestDependencyKey {
    public static let previewValue = GeocodeClient.mock
    public static let testValue = GeocodeClient()
}
