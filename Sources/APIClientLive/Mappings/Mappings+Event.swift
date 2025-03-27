import APIClient
import Foundation
import SharedModels

extension Components.Schemas.EventDto {
    func toDomain() -> Event {
        Event(
            id: self.id,
            name: self.name,
            description: self.description,
            price: self.price,
            date: self.date,
            address: self.address,
            lat: self.lat,
            lng: self.lng,
            author: self.author.toDomain(),
            categories: self.categories.map { $0.toDomain() }
        )
    }
}

extension CreateEventRequest {
    func toAPI() -> Components.Schemas.CreateEventDto {
        Components.Schemas.CreateEventDto(
            name: self.name,
            description: self.description,
            price: self.price,
            date: self.date,
            address: self.address,
            lat: self.lat,
            lng: self.lng,
            categories: self.categories
        )
    }
}

extension UpdateEventRequest {
    func toAPI() -> Components.Schemas.UpdateEventDto {
        Components.Schemas.UpdateEventDto(
            name: self.name,
            description: self.description,
            price: self.price,
            date: self.date,
            lat: self.lat,
            lng: self.lng,
            categories: self.categories
        )
    }
}

extension AutocompleteEventRequest {
    func toAPI() -> Components.Schemas.AutocompleteEventRequestDto {
        Components.Schemas.AutocompleteEventRequestDto(
            name: self.name,
            description: self.description,
            categories: self.categories
        )
    }
}

extension Components.Schemas.AutocompleteEventResponseDto {
    func toDomain() -> AutocompleteEventResponse {
        AutocompleteEventResponse(
            name: self.name ?? "",
            description: self.description ?? "",
            categories: self.categories?.compactMap { $0.toDomain() } ?? []
        )
    }
}

extension Components.Schemas.GetEventsResponseDto {
    func toDomain() -> PaginatedResponse<Event> {
        PaginatedResponse(
            data: self.data.map { $0.toDomain() },
            total: self.total,
            limit: self.limit,
            pagesCount: self.pagesCount
        )
    }
}
