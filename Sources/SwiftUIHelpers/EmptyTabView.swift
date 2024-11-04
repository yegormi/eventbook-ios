import SwiftUI
import Styleguide

public struct EmptyTabView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(.appLogo)
            Text("Coming soon")
                .font(.labelLarge)
                .foregroundStyle(Color.neutral400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
