import APIClient
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OSLog

private let logger = Logger(subsystem: "APIClientLive", category: "ErrorMiddleware")

struct ErrorMiddleware: ClientMiddleware {
    private let decoder = JSONDecoder()

    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (
            HTTPTypes.HTTPResponse,
            OpenAPIRuntime.HTTPBody?
        )
    )
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    {
        let (response, body) = try await next(request, body, baseURL)

        guard response.status.kind == .clientError || response.status.kind == .serverError else {
            return (response, body)
        }
        guard let body else {
            throw APIError.badStatusCodeWithNoBody(response.status.code)
        }

        let errorResponse = try await decoder.decode(
            Components.Schemas.ApiErrorDto.self,
            from: Data(collecting: body, upTo: .max)
        )

        throw APIError.withPayload(errorResponse.toDomain())
    }
}
