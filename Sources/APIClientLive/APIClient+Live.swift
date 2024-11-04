import APIClient
import Dependencies
import DependenciesMacros
import Foundation
import SharedModels

extension APIClient: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.continuousClock) var clock

        let client = DataService.shared

        return APIClient(
            fetchBalance: {
                try await clock.sleep(for: .seconds(1))
                return try await client.loadMockData(filename: "balance", type: AppBalance.self)
            },
            fetchCards: {
                try await clock.sleep(for: .seconds(2))
                return try await client.loadMockData(filename: "cards", type: AppCards.self)
            },
            fetchTransactions: {
                try await clock.sleep(for: .seconds(3))
                return try await client.loadMockData(filename: "transactions", type: [CardTransaction].self)
            }
        )
        
    }
}
