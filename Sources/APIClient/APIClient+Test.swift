import Dependencies
import Foundation
import XCTestDynamicOverlay

extension APIClient: TestDependencyKey {
    public static let testValue = Self()

    public static let previewValue: APIClient = .mock
}
