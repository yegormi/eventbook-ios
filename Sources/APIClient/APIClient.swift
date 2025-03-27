import Dependencies
import DependenciesMacros
import SharedModels
import SwiftUI
import XCTestDynamicOverlay

@DependencyClient
public struct APIClient: Sendable {
    // MARK: - User endpoints

    public var getCurrentUser: @Sendable () async throws -> User
    public var updateCurrentUser: @Sendable (UpdateUserRequest) async throws -> Void
    public var deleteCurrentUser: @Sendable () async throws -> Void

    // MARK: - Category endpoints

    public var createCategory: @Sendable (CreateCategoryRequest) async throws -> EventCategory
    public var getAllCategories: @Sendable () async throws -> [EventCategory]
    public var getCategoryById: @Sendable (String) async throws -> EventCategory
    public var updateCategoryById: @Sendable (String, UpdateCategoryRequest) async throws -> Void
    public var deleteCategoryById: @Sendable (String) async throws -> Void

    // MARK: - Event endpoints

    public var createEvent: @Sendable (CreateEventRequest) async throws -> Event
    public var getAllEvents: @Sendable (GetEventsParams) async throws -> PaginatedResponse<Event>
    public var getNearbyEvents: @Sendable (Double, Double) async throws -> [Event]
    public var autocompleteEvent: @Sendable (AutocompleteEventRequest) async throws -> AutocompleteEventResponse
    public var getMyEvents: @Sendable (GetEventsParams) async throws -> PaginatedResponse<Event>
    public var getSimilarEvents: @Sendable (String, GetEventsParams) async throws -> PaginatedResponse<Event>
    public var getEventById: @Sendable (String) async throws -> Event
    public var updateEventById: @Sendable (String, UpdateEventRequest) async throws -> Void
    public var deleteEventById: @Sendable (String) async throws -> Void

    // MARK: - Ticket endpoints

    public var createTicket: @Sendable (String) async throws -> Ticket
    public var getTicketByEventId: @Sendable (String) async throws -> Ticket
    public var getMyTickets: @Sendable (GetTicketsParams) async throws -> PaginatedResponse<Ticket>
    public var getTicketById: @Sendable (String) async throws -> Ticket

    // MARK: - Review endpoints

    public var createReview: @Sendable (String, CreateReviewRequest) async throws -> Review
    public var getReviewsByEventId: @Sendable (String, GetReviewsParams) async throws -> PaginatedResponse<Review>
    public var getMyReviews: @Sendable (GetReviewsParams) async throws -> PaginatedResponse<Review>
    public var updateReview: @Sendable (String, UpdateReviewRequest) async throws -> Review
    public var getReviewById: @Sendable (String) async throws -> Review
    public var deleteReview: @Sendable (String) async throws -> Review
}

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
