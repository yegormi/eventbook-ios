import APIClient
import Dependencies
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OSLog
import SessionClient

struct AuthenticationMiddleware: ClientMiddleware {
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
        @Dependency(\.session) var session
        var request = request
        if let token = try session.currentAuthenticationToken() {
            request.headerFields[.authorization] = "Bearer \(token)"
        }
        return try await next(request, body, baseURL)
    }
}
