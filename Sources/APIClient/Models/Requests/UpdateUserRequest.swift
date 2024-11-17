import Foundation

public struct UpdateUserRequest: Sendable {
    public let fullName: String

    public init(fullName: String) {
        self.fullName = fullName
    }
}
