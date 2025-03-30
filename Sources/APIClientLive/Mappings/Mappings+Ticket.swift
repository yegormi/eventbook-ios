import APIClient
import Foundation
import SharedModels

extension Components.Schemas.TicketDto {
    func toDomain() -> Ticket {
        Ticket(
            id: self.id,
            event: self.event.value1.toDomain(),
            owner: self.owner.value1.toDomain(),
            createdAt: self.createdAt
        )
    }
}

extension Components.Schemas.GetTicketsResponseDto {
    func toDomain() -> PaginatedResponse<Ticket> {
        PaginatedResponse(
            data: self.data.map { $0.toDomain() },
            total: self.total,
            limit: self.limit,
            // TODO: pagesCount should be always returned, fix after API is done
            pagesCount: self.pagesCount ?? 0
        )
    }
}
