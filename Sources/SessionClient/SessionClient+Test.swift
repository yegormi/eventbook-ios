import Dependencies
import XCTestDynamicOverlay

extension SessionClient: TestDependencyKey {
    public static let mock = Self(
        authenticate: { _ in },
        setCurrentAccessToken: { _ in },
        currentAccessToken: { nil },
        currentUser: { .mock },
        currentUsers: { .never },
        logout: {}
    )

    public static let previewValue: SessionClient = .mock
}
