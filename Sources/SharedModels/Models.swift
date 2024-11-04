import Foundation

public enum CardStatus: String, Codable, Equatable {
    case active
    case locked
    case terminated
}

public enum TransactionStatus: String, Codable, Equatable {
    case completed
    case pending
    case failed
}

public enum TransactionType: String, Codable, Equatable {
    case deposit
    case withdrawal
}

public enum LimitType: String, Codable, Equatable {
    case daily = "PerDay"
    case weekly = "PerWeek"
    case monthly = "PerMonth"
}

public struct AppBalance: Codable, Equatable {
    public let balance: Decimal
    
    public init(balance: Decimal) {
        self.balance = balance
    }
}

public struct AppCards: Codable, Equatable {
    public let cards: [AppCard]
}

public struct CardHolder: Codable, Equatable {
    public let id: UUID
    public let fullName: String
    public let email: String
    public let logoUrl: URL
}

public struct AppCard: Codable, Identifiable, Equatable {
    public let id: UUID
    public let cardLast4: String
    public let cardName: String
    public let isLocked: Bool
    public let isTerminated: Bool
    public let spent: Decimal
    public let limit: Decimal
    public let limitType: LimitType
    public let cardHolder: CardHolder
    public let fundingSource: String
    public let issuedAt: Date
    
    public init(
        id: UUID,
        cardLast4: String,
        cardName: String,
        isLocked: Bool,
        isTerminated: Bool,
        spent: Decimal,
        limit: Decimal,
        limitType: LimitType,
        cardHolder: CardHolder,
        fundingSource: String,
        issuedAt: Date
    ) {
        self.id = id
        self.cardLast4 = cardLast4
        self.cardName = cardName
        self.isLocked = isLocked
        self.isTerminated = isTerminated
        self.spent = spent
        self.limit = limit
        self.limitType = limitType
        self.cardHolder = cardHolder
        self.fundingSource = fundingSource
        self.issuedAt = issuedAt
    }
}

public struct CardTransaction: Codable, Identifiable, Equatable {
    public let id: UUID
    public let tribeTransactionId: UUID
    public let tribeCardId: Int
    public let amount: Decimal
    public let status: TransactionStatus
    public let tribeTransactionType: TransactionType
    public let schemeId: UUID
    public let merchantName: String
    public let pan: String
    
    public init(
        id: UUID,
        tribeTransactionId: UUID,
        tribeCardId: Int,
        amount: Decimal,
        status: TransactionStatus,
        tribeTransactionType: TransactionType,
        schemeId: UUID,
        merchantName: String,
        pan: String
    ) {
        self.id = id
        self.tribeTransactionId = tribeTransactionId
        self.tribeCardId = tribeCardId
        self.amount = amount
        self.status = status
        self.tribeTransactionType = tribeTransactionType
        self.schemeId = schemeId
        self.merchantName = merchantName
        self.pan = pan
    }
}

