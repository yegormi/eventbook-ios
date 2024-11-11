import SharedModels

public extension APIClient {
    static let mock = Self(
        getCurrentUser: { .mock },
        deleteCurrentUser: {}
    )
}
