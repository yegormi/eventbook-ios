import SharedModels

public extension APIClient {
    static var mock = Self(
        fetchBalance: { .mock },
        fetchCards: { .mock },
        fetchTransactions: { [.mock1, .mock2] }
    )
}
