import APIClient
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OSLog

private let logger = Logger(subsystem: "APIClientLive", category: "LoggingMiddleware")

struct LoggingMiddleware: ClientMiddleware {
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
        let (response, responseBody) = try await next(request, body, baseURL)

        let requestMessage = """
        🚀 Outgoing Request

        Method: \(request.method.rawValue)
        URL: \(baseURL.appendingPathComponent(request.path ?? "").absoluteString)
        Headers:
        \(request.headerFields.map { "\t\($0.name): \($0.value)" }.joined(separator: "\n"))
        """
        logger.debug("\(requestMessage)")

        let responseMessage = """
        📥 Incoming Response

        URL: \(baseURL.appendingPathComponent(request.path ?? "").absoluteString)
        Status Code: \(response.status.code)
        Headers:
        \(response.headerFields.map { "\t\($0.name): \($0.value)" }.joined(separator: "\n"))
        """
        logger.debug("\(responseMessage)")

        return (response, responseBody)
    }
}

private extension OpenAPIRuntime.HTTPBody {
    func prettyStringRepresentation() async throws -> String? {
        guard
            let object = try? await JSONSerialization.jsonObject(with: Data(collecting: self, upTo: .max), options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }
        return prettyPrintedString
    }
}
