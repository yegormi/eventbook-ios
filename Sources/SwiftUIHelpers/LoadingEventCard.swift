import Styleguide
import SwiftUI

public struct LoadingEventCard: View {
    public init() {}

    public var body: some View {
        CardContainer {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.neutral400.opacity(0.5))
                        .frame(width: 100, height: 16)
                        .shimmerEffect()

                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.neutral400.opacity(0.5))
                        .frame(width: 150, height: 16)
                        .shimmerEffect()
                }

                Spacer(minLength: 8)

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.neutral400.opacity(0.5))
                        .frame(width: 55, height: 14)
                        .shimmerEffect()

                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                }
            }
        }
    }
}

#Preview {
    LoadingEventCard()
}
