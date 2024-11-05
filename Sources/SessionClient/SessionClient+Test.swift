import Dependencies
import XCTestDynamicOverlay

extension SessionClient: TestDependencyKey {
    public static let mock = Self(
        authenticate: { _ in },
        setCurrentAuthenticationToken: { _ in },
        currentAuthenticationToken: { nil },
        currentUser: { .mock },
        currentUsers: { .never },
        logout: {}
    )

    public static let previewValue: SessionClient = .mock
}
