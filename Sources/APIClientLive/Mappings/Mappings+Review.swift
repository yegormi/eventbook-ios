import APIClient
import Foundation
import SharedModels

extension Components.Schemas.ReviewDto {
    func toDomain() -> Review {
        Review(
            id: self.id,
            event: self.event.value1.toDomain(),
            author: self.author.value1.toDomain(),
            title: self.title,
            content: self.content,
            rating: self.rating,
            createdAt: self.createdAt
        )
    }
}

extension CreateReviewRequest {
    func toAPI() -> Components.Schemas.CreateReviewDto {
        Components.Schemas.CreateReviewDto(
            title: self.title,
            content: self.content,
            rating: self.rating
        )
    }
}

extension UpdateReviewRequest {
    func toAPI() -> Components.Schemas.UpdateReviewDto {
        Components.Schemas.UpdateReviewDto(
            title: self.title,
            content: self.content,
            rating: self.rating
        )
    }
}

extension Components.Schemas.GetReviewsResponseDto {
    func toDomain() -> PaginatedResponse<Review> {
        PaginatedResponse(
            data: self.data.map { $0.toDomain() },
            total: self.total,
            limit: self.limit,
            pagesCount: self.pagesCount ?? 0
        )
    }
}
