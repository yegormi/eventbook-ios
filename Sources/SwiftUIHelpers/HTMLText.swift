import SwiftHelpers
import SwiftUI

public struct HTMLText: View {
    public let htmlContent: String

    public init(htmlContent: String) {
        self.htmlContent = htmlContent
    }

    public var body: some View {
        Text(self.htmlContent.htmlAttributed())
            .lineSpacing(8)
    }
}
