import Foundation

public extension AppBalance {
    static var mock: AppBalance {
        return AppBalance(balance: 32576.97)
    }
}

public extension CardHolder {
    static var mock: CardHolder {
        return CardHolder(
            id: UUID(),
            fullName: "Jane Smith",
            email: "jane.smith@example.com",
            logoUrl: URL(string: "https://example.com/logo.png")!
        )
    }
}

public extension AppCard {
    static var mock1: AppCard {
        AppCard(
            id: UUID(),
            cardLast4: "5678",
            cardName: "Business Card",
            isLocked: false,
            isTerminated: false,
            spent: 500.75,
            limit: 5000.00,
            limitType: .monthly,
            cardHolder: .mock,
            fundingSource: "ACH",
            issuedAt: Date()
        )
    }
    
    static var mock2: AppCard {
        AppCard(
            id: UUID(),
            cardLast4: "1234",
            cardName: "Personal Card",
            isLocked: false,
            isTerminated: false,
            spent: 150.50,
            limit: 2000.00,
            limitType: .monthly,
            cardHolder: .mock,
            fundingSource: "Wire Transfer",
            issuedAt: Date()
        )
    }
    
    static var mock3: AppCard {
        AppCard(
            id: UUID(),
            cardLast4: "9876",
            cardName: "Travel Card",
            isLocked: true,
            isTerminated: false,
            spent: 300.00,
            limit: 3000.00,
            limitType: .weekly,
            cardHolder: .mock,
            fundingSource: "Credit",
            issuedAt: Date()
        )
    }
}

public extension AppCards {
    static var mock: AppCards {
        AppCards(cards: [.mock1, .mock2, .mock3])
    }
}

public extension CardTransaction {
    static var mock1: CardTransaction {
        CardTransaction(
            id: UUID(),
            tribeTransactionId: UUID(),
            tribeCardId: 1,
            amount: 200.00,
            status: .completed,
            tribeTransactionType: .deposit,
            schemeId: UUID(),
            merchantName: "Stripe",
            pan: "5678"
        )
    }
    
    static var mock2: CardTransaction {
        CardTransaction(
            id: UUID(),
            tribeTransactionId: UUID(),
            tribeCardId: 1,
            amount: 75.50,
            status: .pending,
            tribeTransactionType: .withdrawal,
            schemeId: UUID(),
            merchantName: "PayPal",
            pan: "1234"
        )
    }
    
    static var mock3: CardTransaction {
        CardTransaction(
            id: UUID(),
            tribeTransactionId: UUID(),
            tribeCardId: 2,
            amount: 150.75,
            status: .completed,
            tribeTransactionType: .deposit,
            schemeId: UUID(),
            merchantName: "Square",
            pan: "9876"
        )
    }
}
