import SharedModels
import Styleguide
import SwiftUI

public struct AvatarView<Model: FullNameRepresentable, ClipShape: Shape>: View {
    public let model: Model
    public let photoURL: URL?
    public let size: CGFloat?
    public let clipShape: ClipShape

    public init(
        model: Model,
        photoURL: URL? = nil,
        size: CGFloat? = nil,
        clipShape: ClipShape
    ) {
        self.model = model
        self.photoURL = photoURL
        self.size = size
        self.clipShape = clipShape
    }

    public var body: some View {
        Group {
            if let photoURL {
                self.avatarView(for: photoURL)
            } else {
                self.defaultAvatarView
            }
        }
        .frame(width: self.size, height: self.size)
        .clipShape(self.clipShape)
        .accessibilityLabel("\(self.model.personFullName)'s avatar")
    }

    private func avatarView(for imageURL: URL) -> some View {
        AsyncImage(
            url: imageURL,
            transaction: Transaction(animation: .easeInOut)
        ) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.neutral400)
                    .shimmerEffect()

            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)

            case .failure:
                self.defaultAvatarView

            @unknown default:
                self.defaultAvatarView
            }
        }
    }

    private var defaultAvatarView: some View {
        DefaultAvatarView(model: self.model)
    }
}

// MARK: - Convenience Types

/// Circle shape avatar view
public typealias CircleAvatarView<Model: FullNameRepresentable> = AvatarView<Model, Circle>

/// Rectangle shape avatar view
public typealias RectangleAvatarView<Model: FullNameRepresentable> = AvatarView<Model, Rectangle>

// MARK: - Convenience Initializers

public extension AvatarView where ClipShape == Circle {
    init(
        model: Model,
        photoURL: URL? = nil,
        size: CGFloat? = nil
    ) {
        self.init(
            model: model,
            photoURL: photoURL,
            size: size,
            clipShape: Circle()
        )
    }
}

public extension AvatarView where ClipShape == Rectangle {
    init(
        model: Model,
        photoURL: URL? = nil,
        size: CGFloat? = nil
    ) {
        self.init(
            model: model,
            photoURL: photoURL,
            size: size,
            clipShape: Rectangle()
        )
    }
}
