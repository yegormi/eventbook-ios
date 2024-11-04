import Dependencies
import Foundation
import XCTestDynamicOverlay

extension APIClient: TestDependencyKey {
    public static var testValue = Self()

    public static var previewValue: APIClient = .mock
}
