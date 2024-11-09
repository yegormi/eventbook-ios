import SharedModels

public extension APIClient {
    static let mock = Self(
        signup: { _ in .mock },
        login: { _ in .mock },
        deleteCurrentUser: {},
        getCurrentUser: { .mock }
    )
}
