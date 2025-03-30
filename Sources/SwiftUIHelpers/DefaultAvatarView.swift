import SharedModels
import Styleguide
import SwiftUI

public struct DefaultAvatarView<Model: FullNameRepresentable>: View {
    private let model: Model

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        GeometryReader { geometry in
            Color.neutral400
                .overlay {
                    Text(self.model.initials)
                        .font(.system(size: geometry.size.width * 0.3, weight: .medium))
                        .foregroundStyle(Color.white)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
