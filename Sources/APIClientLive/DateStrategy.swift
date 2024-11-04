import Foundation

struct ISO8601DateTranscoderWithFractions {
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
