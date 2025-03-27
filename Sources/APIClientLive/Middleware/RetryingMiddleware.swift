import APIClient
import Dependencies
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OSLog
import SessionClient

private let logger = Logger(subsystem: "APIClientLive", category: "RetryingMiddleware")

/// A middleware that automatically retries HTTP requests based on configurable conditions.
struct RetryingMiddleware {
    /// The failure signal that can lead to a retried request.
    ///
    /// This enum defines the conditions under which a request should be retried.
    enum RetryableSignal: Hashable {
        /// Retry if the response code matches this specific code.
        /// Useful for handling specific error cases like 429 (Too Many Requests).
        case code(Int)

        /// Retry if the response code falls into this range.
        /// Useful for handling ranges of errors like 500-599 (Server Errors).
        case range(Range<Int>)

        /// Retry if an error is thrown by a downstream middleware or transport.
        /// This catches network failures and other exceptions.
        case errorThrown
    }

    /// The policy to use when a retryable signal hints that a retry might be appropriate.
    ///
    /// This enum defines how many retry attempts should be made.
    enum RetryingPolicy: Hashable {
        /// Don't retry any requests, regardless of the signal.
        case never

        /// Retry up to the provided number of attempts.
        /// For example, `.upToAttempts(count: 3)` will try the original request
        /// plus up to 3 additional attempts, for a total of 4 attempts.
        case upToAttempts(count: Int)
    }

    /// The policy of delaying the retried request.
    ///
    /// This enum defines how long to wait between retry attempts.
    enum DelayPolicy: Hashable {
        /// Don't delay, retry immediately.
        /// Use with caution as rapid retries can overwhelm systems.
        case none

        /// Constant delay between retry attempts.
        /// Provides a predictable spacing between requests.
        case constant(seconds: TimeInterval)

        /// Exponential backoff delay between retry attempts.
        /// Delay increases exponentially with each retry: baseDelay * (multiplier ^ attemptNumber)
        /// - Parameters:
        ///   - baseDelay: The initial delay in seconds
        ///   - multiplier: The multiplier applied to each subsequent retry
        ///   - jitter: Random factor (0 to 1) to add variability to delays, preventing thundering herd problems
        case exponentialBackoff(baseDelay: TimeInterval, multiplier: Double, jitter: Double = 0.2)
    }

    /// The signals that lead to the retry policy being evaluated.
    ///
    /// This set contains the conditions that will trigger a retry.
    var signals: Set<RetryableSignal>

    /// The policy used to evaluate whether to perform a retry.
    ///
    /// This determines how many retry attempts will be made.
    var policy: RetryingPolicy

    /// The delay policy for retries.
    ///
    /// This determines how long to wait between retry attempts.
    var delay: DelayPolicy

    /// Creates a new retrying middleware with configurable retry behavior.
    ///
    /// - Parameters:
    ///   - signals: The signals that lead to the retry policy being evaluated.
    ///     Default is [.code(429), .range(500..<600), .errorThrown], which retries on:
    ///     - 429 Too Many Requests
    ///     - All 5xx server errors
    ///     - Any thrown errors
    ///   - policy: The policy used to evaluate whether to perform a retry.
    ///     Default is .upToAttempts(count: 3), which will retry up to 3 times.
    ///   - delay: The delay policy for retries.
    ///     Default is .constant(seconds: 1), which waits 1 second between retries.
    init(
        signals: Set<RetryableSignal> = [.code(429), .range(500 ..< 600), .errorThrown],
        policy: RetryingPolicy = .upToAttempts(count: 3),
        delay: DelayPolicy = .constant(seconds: 1)
    ) {
        self.signals = signals
        self.policy = policy
        self.delay = delay
    }
}

extension RetryingMiddleware: ClientMiddleware {
    /// Intercepts the HTTP request and implements the retry logic.
    ///
    /// This method:
    /// 1. Checks if the retry policy is configured to retry
    /// 2. Ensures the request body can be iterated multiple times if present
    /// 3. Attempts the request
    /// 4. If the response matches a retry signal and we haven't exceeded max attempts, retries
    /// 5. Applies appropriate delays between retries based on the delay policy
    ///
    /// - Parameters:
    ///   - request: The HTTP request to be sent
    ///   - body: The HTTP body of the request
    ///   - baseURL: The base URL for the request
    ///   - operationID: A string identifying the operation being performed
    ///   - next: The next middleware or handler in the chain
    /// - Returns: A tuple containing the HTTP response and body
    /// - Throws: Any errors that occur during the request or that are not handled by retries
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        /// Skip retry logic if policy is set to never retry
        guard case let .upToAttempts(count: maxAttemptCount) = policy else {
            return try await next(request, body, baseURL)
        }

        /// Ensure body can be iterated multiple times if present
        if let body {
            guard body.iterationBehavior == .multiple else {
                return try await next(request, body, baseURL)
            }
        }

        /// Function to handle delays between retry attempts
        func willRetry(attempt: Int) async throws {
            switch self.delay {
            case .none:
                return
            case let .constant(seconds: seconds):
                try await Task.sleep(for: .seconds(seconds))
            case let .exponentialBackoff(baseDelay: baseDelay, multiplier: multiplier, jitter: jitter):
                /// Calculate delay with exponential backoff
                let attemptFactor = pow(multiplier, Double(attempt - 1))
                let calculatedDelay = baseDelay * attemptFactor

                /// Apply jitter to prevent thundering herd problem
                let jitterFactor = 1.0 - jitter + (jitter * 2 * Double.random(in: 0 ... 1))
                let finalDelay = calculatedDelay * jitterFactor

                logger.debug("Exponential backoff: Attempt \(attempt), delay: \(finalDelay) seconds")
                try await Task.sleep(for: .seconds(finalDelay))
            }
        }

        /// Attempt the request up to maxAttemptCount times
        for attempt in 1 ... maxAttemptCount {
            logger.debug("Attempt \(attempt) for operation \(operationID)")

            let (response, responseBody): (HTTPResponse, HTTPBody?)

            /// Handle error-based retries
            if self.signals.contains(.errorThrown) {
                do {
                    (response, responseBody) = try await next(request, body, baseURL)
                } catch {
                    /// If this is the last attempt, propagate the error
                    if attempt == maxAttemptCount {
                        throw error
                    } else {
                        /// Otherwise, log and retry
                        logger.info("Retrying after an error for operation \(operationID): \(error.localizedDescription)")
                        try await willRetry(attempt: attempt)
                        continue
                    }
                }
            } else {
                /// If not retrying on errors, just make the request
                (response, responseBody) = try await next(request, body, baseURL)
            }

            /// Handle status code-based retries
            if self.signals.contains(response.status.code) && attempt < maxAttemptCount {
                logger.info("Retrying with code \(response.status.code) for operation \(operationID)")
                try await willRetry(attempt: attempt)
                continue
            } else {
                /// Either success or we've run out of attempts
                logger.debug(
                    "Returning the received response for operation \(operationID), either because of success or ran out of attempts."
                )
                return (response, responseBody)
            }
        }

        /// This point should never be reached due to the loop structure
        preconditionFailure("Unreachable")
    }
}

extension Set where Element == RetryingMiddleware.RetryableSignal {
    /// Checks whether the provided response code matches any of the retryable signals.
    ///
    /// - Parameter code: The HTTP status code to check
    /// - Returns: `true` if the code matches at least one of the signals, `false` otherwise
    func contains(_ code: Int) -> Bool {
        for signal in self {
            switch signal {
            case let .code(int):
                if code == int { return true }
            case let .range(range):
                if range.contains(code) { return true }
            case .errorThrown:
                break
            }
        }
        return false
    }
}
