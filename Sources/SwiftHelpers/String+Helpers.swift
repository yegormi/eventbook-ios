import Foundation

public extension String {
    var isValidEmail: Bool {
        let emailRegex = #/^\S+@\S+\.\S+$/#
        return self.wholeMatch(of: emailRegex) != nil
    }

    func htmlAttributed() -> AttributedString {
        do {
            // Convert the HTML string to NSAttributedString
            guard let data = self.data(using: .utf8) else {
                return AttributedString(self)
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ]

            let nsAttributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )

            // Convert NSAttributedString to AttributedString
            var attributedString = AttributedString(nsAttributedString)

            // Apply some default styling
            attributedString.font = .systemFont(ofSize: 16)
            attributedString.foregroundColor = .label

            return attributedString
        } catch {
            print("Error converting HTML to AttributedString: \(error)")
            return AttributedString(self)
        }
    }
}
