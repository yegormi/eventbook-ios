import Styleguide
import SwiftUI

public struct EmptyTabView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Image(.appLogo)
                .resizable()
                .frame(maxWidth: 200, maxHeight: 200)
            Text("Coming soon")
                .font(.labelLarge)
                .foregroundStyle(Color.neutral400)
        }
    }
}
