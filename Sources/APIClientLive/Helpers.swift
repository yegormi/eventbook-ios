import Foundation
import Tagged

extension Tagged where RawValue == UUID {
    init(validating uuidString: String) throws {
        guard let uuid = UUID(uuidString: uuidString) else {
            throw UUIDConversionError()
        }
        self.init(rawValue: uuid)
    }
}

struct UUIDConversionError: Error {}
struct ImageConversionError: Error {}

extension DateComponents {
    /// Returns the components formatted as HH:mm:ss in the current timezone
    var timeFormatted: String {
        // Format the time with the current timezone
        // so if the user chose 20:30 in the input field
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = .autoupdatingCurrent

        // Used to be able to get formatting to work
        // probably need a better solution
        // swiftlint:disable force_unwrapping
        let date = Calendar.autoupdatingCurrent.date(
            bySettingHour: self.hour!,
            minute: self.minute!,
            second: 0,
            of: .now
        )!
        // swiftlint:enable force_unwrapping
        return formatter.string(from: date)
    }
}

private struct StringDateParsingError: Error {}

private let dateOnlyFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .autoupdatingCurrent
    return formatter
}()

extension String {
    /// Expects the string to be `2021-11-01` for example.
    var parsedAsDate: Date {
        get throws {
            guard let date = dateOnlyFormatter.date(from: self) else {
                throw StringDateParsingError()
            }
            return date
        }
    }
}

extension Date {
    var formattedAsDateOnly: String {
        dateOnlyFormatter.string(from: self)
    }
}
