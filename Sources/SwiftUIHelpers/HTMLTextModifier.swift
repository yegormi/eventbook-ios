import Foundation
import SwiftUI

public extension String {
    // swiftlint:disable function_body_length
    func htmlToAttributedString(
        defaultFont: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .label,
        linkColor: UIColor = .systemBlue
    ) -> NSAttributedString? {
        let fontFamily = defaultFont.familyName
        let fontSize = defaultFont.pointSize
        let textColorHex = self.hexString(from: textColor)
        let linkColorHex = self.hexString(from: linkColor)

        let css = """
        <style>
            body {
                font-family: '\(fontFamily)', -apple-system;
                font-size: \(fontSize)px;
                color: \(textColorHex);
                line-height: 1.4;
            }
            b, strong {
                font-weight: bold;
            }
            i, em {
                font-style: italic;
            }
            a {
                color: \(linkColorHex);
                text-decoration: none;
            }
            ul, ol {
                padding-left: 20px;
                margin-top: 8px;
                margin-bottom: 8px;
            }
            li {
                margin-bottom: 8px;
            }
            p {
                margin-top: 0;
                margin-bottom: 8px;
            }
        </style>
        """

        let modifiedHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            \(css)
        </head>
        <body>
            \(self)
        </body>
        </html>
        """

        guard let data = modifiedHtml.data(using: .utf8) else { return nil }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )

            return attributedString
        } catch {
            print("Error converting HTML to AttributedString: \(error)")
            return nil
        }
        // swiftlint:enable function_body_length
    }

    func hexString(from color: UIColor) -> String {
        // swiftlint:disable identifier_name
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        // swiftlint:enable identifier_name

        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(
            format: "#%02lX%02lX%02lX",
            lround(r * 255),
            lround(g * 255),
            lround(b * 255)
        )
    }
}

public extension Text {
    static func html(
        _ htmlString: String,
        font: Font = .body,
        textColor: Color = .primary,
        linkColor: Color = .blue
    ) -> Text? {
        let uiFont = switch font {
        case .largeTitle:
            UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            UIFont.preferredFont(forTextStyle: .title1)
        case .title2:
            UIFont.preferredFont(forTextStyle: .title2)
        case .title3:
            UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            UIFont.preferredFont(forTextStyle: .subheadline)
        case .body:
            UIFont.preferredFont(forTextStyle: .body)
        case .callout:
            UIFont.preferredFont(forTextStyle: .callout)
        case .footnote:
            UIFont.preferredFont(forTextStyle: .footnote)
        case .caption:
            UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            UIFont.preferredFont(forTextStyle: .caption2)
        default:
            UIFont.preferredFont(forTextStyle: .body)
        }

        guard
            let attributedString = htmlString.htmlToAttributedString(
                defaultFont: uiFont,
                textColor: UIColor(textColor),
                linkColor: UIColor(linkColor)
            )
        else {
            return nil
        }

        // Convert to SwiftUI's AttributedString format
        return Text(AttributedString(attributedString))
    }
}

struct HTMLTextModifier: ViewModifier {
    let htmlContent: String
    let font: Font
    let textColor: Color
    let linkColor: Color

    func body(content _: Content) -> some View {
        if
            let htmlText = Text.html(
                htmlContent,
                font: font,
                textColor: textColor,
                linkColor: linkColor
            )
        {
            htmlText
        } else {
            Text(self.htmlContent)
                .font(self.font)
                .foregroundColor(self.textColor)
        }
    }
}

public extension View {
    func htmlText(
        _ htmlContent: String,
        font: Font = .body,
        textColor: Color = .primary,
        linkColor: Color = .blue
    ) -> some View {
        self.modifier(HTMLTextModifier(
            htmlContent: htmlContent,
            font: font,
            textColor: textColor,
            linkColor: linkColor
        ))
    }
}

// Example usage:
struct HTMLAttributedTextExample: View {
    let htmlContent = """
    <p>This is a <b>bold text</b> and this is <i>italic text</i>.</p>
    <p>Here's a list of items:</p>
    <ul>
        <li>First item with <b>bold text</b></li>
        <li>Second item with <a href="https://example.com">link</a></li>
        <li>Third item with <i>italic text</i></li>
    </ul>
    """

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("HTML Content Example")
                .font(.headline)

            if let htmlText = Text.html(htmlContent) {
                htmlText
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview {
    HTMLAttributedTextExample()
}
