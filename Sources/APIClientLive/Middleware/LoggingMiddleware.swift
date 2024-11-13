import Foundation
import HTTPTypes
import OpenAPIRuntime
import OSLog

private let defaultLogger = Logger(subsystem: "APIClientLive", category: "LoggingMiddleware")

package actor LoggingMiddleware {
    private let logger: Logger
    package let bodyLoggingPolicy: BodyLoggingPolicy

    package init(
        logger: Logger = defaultLogger,
        bodyLoggingConfiguration: BodyLoggingPolicy = .never
    ) {
        self.logger = logger
        self.bodyLoggingPolicy = bodyLoggingConfiguration
    }
}

extension LoggingMiddleware: ClientMiddleware {
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    )
        async throws -> (HTTPResponse, HTTPBody?)
    {
        let (requestBodyToLog, requestBodyForNext) = try await bodyLoggingPolicy.process(body)
        logOutgoingRequest(request, baseURL: baseURL, body: requestBodyToLog)

        do {
            let (response, responseBody) = try await next(request, requestBodyForNext, baseURL)
            let (responseBodyToLog, responseBodyForNext) = try await bodyLoggingPolicy.process(responseBody)
            logIncomingResponse(request, response: response, baseURL: baseURL, body: responseBodyToLog)
            return (response, responseBodyForNext)
        } catch {
            logRequestFailure(request, error: error)
            throw error
        }
    }
}

extension LoggingMiddleware: ServerMiddleware {
    package func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        metadata: OpenAPIRuntime.ServerRequestMetadata,
        operationID _: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, OpenAPIRuntime.ServerRequestMetadata)
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    )
        async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    {
        let (requestBodyToLog, requestBodyForNext) = try await bodyLoggingPolicy.process(body)
        logOutgoingRequest(request, body: requestBodyToLog)

        do {
            let (response, responseBody) = try await next(request, requestBodyForNext, metadata)
            let (responseBodyToLog, responseBodyForNext) = try await bodyLoggingPolicy.process(responseBody)
            logIncomingResponse(request, response: response, body: responseBodyToLog)
            return (response, responseBodyForNext)
        } catch {
            logRequestFailure(request, error: error)
            throw error
        }
    }
}

extension LoggingMiddleware {
    private func logOutgoingRequest(
        _ request: HTTPRequest,
        baseURL: URL? = nil,
        body: BodyLoggingPolicy.BodyLog
    ) {
        let requestMessage = """
        🚀 Outgoing Request
        -------------------------------------
        Method: \(request.method)
        URL: \(baseURL?.appendingPathComponent(request.path ?? "").absoluteString ?? "<none>")
        Headers:
        \(request.headerFields.map { "\t\($0.name): \($0.value)" }.joined(separator: "\n"))
        Body:
        \(body.description)
        -------------------------------------
        """
        self.logger.debug("\(requestMessage)")
    }

    private func logIncomingResponse(
        _ request: HTTPRequest,
        response: HTTPResponse,
        baseURL: URL? = nil,
        body: BodyLoggingPolicy.BodyLog
    ) {
        let responseMessage = """
        📥 Incoming Response
        -------------------------------------
        URL: \(baseURL?.appendingPathComponent(request.path ?? "").absoluteString ?? "<none>")
        Status Code: \(response.status.code)
        Headers:
        \(response.headerFields.map { "\t\($0.name): \($0.value)" }.joined(separator: "\n"))
        Body:
        \(body.description)
        -------------------------------------
        """
        self.logger.debug("\(responseMessage)")
    }

    private func logRequestFailure(_: HTTPRequest, error: any Error) {
        self.logger.warning("Request failed. Error: \(error.localizedDescription)")
    }
}

package enum BodyLoggingPolicy {
    case never
    case upTo(maxBytes: Int)

    enum BodyLog: Equatable, CustomStringConvertible {
        case none
        case redacted
        case unknownLength
        case tooManyBytesToLog(Int64)
        case complete(Data)

        var description: String {
            switch self {
            case .none: return "<none>"
            case .redacted: return "<redacted>"
            case .unknownLength: return "<unknown length>"
            case let .tooManyBytesToLog(byteCount): return "<\(byteCount) bytes>"
            case let .complete(data):
                if let string = String(data: data, encoding: .utf8) { return string }
                return String(describing: data)
            }
        }
    }

    func process(_ body: HTTPBody?) async throws -> (bodyToLog: BodyLog, bodyForNext: HTTPBody?) {
        switch (body?.length, self) {
        case (.none, _): return (.none, body)
        case (_, .never): return (.redacted, body)
        case (.unknown, _): return (.unknownLength, body)
        case let (.known(length), .upTo(maxBytesToLog)) where length > maxBytesToLog:
            return (.tooManyBytesToLog(length), body)
        case let (.known, .upTo(maxBytesToLog)):
            // swiftlint:disable:next force_unwrapping
            let object = try await JSONSerialization.jsonObject(with: Data(collecting: body!, upTo: maxBytesToLog), options: [])
            let bodyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])

            return (.complete(bodyData), HTTPBody(bodyData))
        }
    }
}
