import Dependencies
import DependenciesMacros
import SharedModels
import SwiftUI
import XCTestDynamicOverlay

@DependencyClient
public struct APIClient: Sendable {
    public var fetchBalance: @Sendable () async throws -> AppBalance
    public var fetchCards: @Sendable () async throws -> AppCards
    public var fetchTransactions: @Sendable () async throws -> [CardTransaction]
}

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
