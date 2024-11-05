import Foundation
import OpenAPIRuntime

struct ISO8601DateTranscoderWithFractions: DateTranscoder {
    private let formatterWithFractions: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private let formatterWithoutFractions: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    func encode(_ date: Date) throws -> String {
        self.formatterWithFractions.string(from: date)
    }

    func decode(_ dateString: String) throws -> Date {
        guard
            let date = self.formatterWithFractions.date(from: dateString) ?? self.formatterWithoutFractions
                .date(from: dateString)
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Expected date string to be ISO8601-formatted."
                )
            )
        }
        return date
    }
}

extension DateTranscoder where Self == ISO8601DateTranscoderWithFractions {
    /// A transcoder that transcodes dates as ISO-8601–formatted string (in RFC 3339 format).
    static var iso8601WithFractions: Self {
        ISO8601DateTranscoderWithFractions()
    }
}

extension ISO8601DateFormatter: @unchecked Sendable {}
