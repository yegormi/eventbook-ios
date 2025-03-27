import SharedModels

public extension APIClient {
    static let mock = Self(
        // User endpoints
        getCurrentUser: { .mock },
        updateCurrentUser: { _ in },
        deleteCurrentUser: {},

        // Category endpoints
        createCategory: { _ in .mock },
        getAllCategories: { [.mock] },
        getCategoryById: { _ in .mock },
        updateCategoryById: { _, _ in },
        deleteCategoryById: { _ in },

        // Event endpoints
        createEvent: { _ in .mock },
        getAllEvents: { _ in .mock },
        getNearbyEvents: { _, _ in [.mock] },
        autocompleteEvent: { _ in .mock },
        getMyEvents: { _ in .mock },
        getSimilarEvents: { _, _ in .mock },
        getEventById: { _ in .mock },
        updateEventById: { _, _ in },
        deleteEventById: { _ in },

        // Ticket endpoints
        createTicket: { _ in .mock },
        getTicketByEventId: { _ in .mock },
        getMyTickets: { _ in .mock },
        getTicketById: { _ in .mock },

        // Review endpoints
        createReview: { _, _ in .mock },
        getReviewsByEventId: { _, _ in .mock },
        getMyReviews: { _ in .mock },
        updateReview: { _, _ in .mock },
        getReviewById: { _ in .mock },
        deleteReview: { _ in .mock }
    )
}
