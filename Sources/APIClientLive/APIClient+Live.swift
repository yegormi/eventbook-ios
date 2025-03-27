import APIClient
import Dependencies
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import SharedModels
import SwiftHelpers
import XCTestDynamicOverlay

private func throwingUnderlyingError<T>(_ closure: () async throws -> T) async throws -> T {
    do {
        return try await closure()
    } catch let error as ClientError {
        throw error.underlyingError
    }
}

extension APIClient: DependencyKey {
    public static var liveValue: Self {
        let client = Client(
            serverURL: try! Servers.Server1.url(), // swiftlint:disable:this force_try
            configuration: Configuration(
                dateTranscoder: .iso8601WithFractions
            ),
            transport: URLSessionTransport(),
            middlewares: [
                ErrorMiddleware(),
                AuthenticationMiddleware(),
                LoggingMiddleware(bodyLoggingConfiguration: .upTo(maxBytes: 1024)),
            ]
        )

        return Self(
            // User endpoints
            getCurrentUser: {
                try await throwingUnderlyingError {
                    try await client.getMe().ok.body.json.toDomain()
                }
            },
            updateCurrentUser: { request in
                try await throwingUnderlyingError {
                    _ = try await client.updateMe(body: .json(request.toAPI())).ok
                }
            },
            deleteCurrentUser: {
                try await throwingUnderlyingError {
                    _ = try await client.deleteMe().noContent
                }
            },

            // Category endpoints
            createCategory: { request in
                try await throwingUnderlyingError {
                    try await client.createCategory(body: .json(request.toAPI())).ok.body.json.toDomain()
                }
            },
            getAllCategories: {
                try await throwingUnderlyingError {
                    try await client.getAllCategories().ok.body.json.map { $0.toDomain() }
                }
            },
            getCategoryById: { id in
                try await throwingUnderlyingError {
                    try await client.getCategoryById(path: .init(id: id)).ok.body.json.toDomain()
                }
            },
            updateCategoryById: { id, request in
                try await throwingUnderlyingError {
                    _ = try await client.updateCategoryById(path: .init(id: id), body: .json(request.toAPI())).ok
                }
            },
            deleteCategoryById: { id in
                try await throwingUnderlyingError {
                    _ = try await client.deleteCategoryById(path: .init(id: id)).ok
                }
            },

            // Event endpoints
            createEvent: { request in
                try await throwingUnderlyingError {
                    try await client.createEvent(body: .json(request.toAPI())).ok.body.json.toDomain()
                }
            },
            getAllEvents: { params in
                try await throwingUnderlyingError {
                    try await client.getAllEvents(
                        query: .init(
                            query: params.query,
                            page: params.page,
                            limit: params.limit
                        )
                    ).ok.body.json.toDomain()
                }
            },
            getNearbyEvents: { lat, lng in
                try await throwingUnderlyingError {
                    try await client.getNearbyEvents(query: .init(lat: lat, lng: lng)).ok.body.json.map { $0.toDomain() }
                }
            },
            autocompleteEvent: { request in
                try await throwingUnderlyingError {
                    try await client.autocompleteEvent(body: .json(request.toAPI())).ok.body.json.toDomain()
                }
            },
            getMyEvents: { params in
                try await throwingUnderlyingError {
                    try await client.getMyEvents(
                        query: .init(
                            query: params.query,
                            page: params.page,
                            limit: params.limit
                        )
                    ).ok.body.json.toDomain()
                }
            },
            getSimilarEvents: { id, params in
                try await throwingUnderlyingError {
                    try await client.getSimilarEvents(
                        path: .init(id: id),
                        query: .init(
                            query: params.query,
                            page: params.page,
                            limit: params.limit
                        )
                    ).ok.body.json.toDomain()
                }
            },
            getEventById: { id in
                try await throwingUnderlyingError {
                    try await client.getEventById(path: .init(id: id)).ok.body.json.toDomain()
                }
            },
            updateEventById: { id, request in
                try await throwingUnderlyingError {
                    _ = try await client.updateEventById(path: .init(id: id), body: .json(request.toAPI())).ok
                }
            },
            deleteEventById: { id in
                try await throwingUnderlyingError {
                    _ = try await client.deleteEventById(path: .init(id: id)).ok
                }
            },

            // Ticket endpoints
            createTicket: { eventId in
                try await throwingUnderlyingError {
                    try await client.createTicket(path: .init(eventId: eventId)).ok.body.json.toDomain()
                }
            },
            getTicketByEventId: { eventId in
                try await throwingUnderlyingError {
                    try await client.getTicketByEventId(path: .init(eventId: eventId)).ok.body.json.toDomain()
                }
            },
            getMyTickets: { params in
                try await throwingUnderlyingError {
                    try await client.getMyTickets(
                        query: .init(
                            query: params.query,
                            limit: params.limit,
                            page: params.page
                        )
                    ).ok.body.json.toDomain()
                }
            },
            getTicketById: { id in
                try await throwingUnderlyingError {
                    try await client.getTicketById(path: .init(id: id)).ok.body.json.toDomain()
                }
            },

            // Review endpoints
            createReview: { eventId, request in
                try await throwingUnderlyingError {
                    try await client.createReview(
                        path: .init(eventId: eventId),
                        body: .json(request.toAPI())
                    ).ok.body.json.toDomain()
                }
            },
            getReviewsByEventId: { eventId, params in
                try await throwingUnderlyingError {
                    try await client.getReviewsByEventId(
                        path: .init(eventId: eventId),
                        query: .init(
                            query: params.query,
                            limit: params.limit,
                            page: params.page
                        )
                    ).ok.body.json.toDomain()
                }
            },
            getMyReviews: { params in
                try await throwingUnderlyingError {
                    try await client.getMyReviews(
                        query: .init(
                            query: params.query,
                            limit: params.limit,
                            page: params.page
                        )
                    ).ok.body.json.toDomain()
                }
            },
            updateReview: { id, request in
                try await throwingUnderlyingError {
                    try await client.updateReview(
                        path: .init(id: id),
                        body: .json(request.toAPI())
                    ).ok.body.json.toDomain()
                }
            },
            getReviewById: { id in
                try await throwingUnderlyingError {
                    try await client.getReviewById(path: .init(id: id)).ok.body.json.toDomain()
                }
            },
            deleteReview: { id in
                try await throwingUnderlyingError {
                    try await client.deleteReview(path: .init(id: id)).ok.body.json.toDomain()
                }
            }
        )
    }
}
