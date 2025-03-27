import SwiftUI

public struct CardContainer<Content: View>: View {
    private let edges: Edge.Set
    private let length: CGFloat?
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.edges = .all
        self.length = 12
    }

    public init(padding: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.edges = .all
        self.length = padding
    }

    public init(padding: Edge.Set, _ length: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.edges = padding
        self.length = length
    }

    public var body: some View {
        self.content
            .padding(self.edges, self.length)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primaryInverted)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        CardContainer {
            Text("Default Padding")
                .padding(100)
        }

        CardContainer(padding: 24) {
            Text("Custom All-Side Padding: 24")
                .padding(100)
        }

        CardContainer(padding: .vertical, 48) {
            Text("Custom Vertical Padding: 48")
                .padding(100)
        }

        CardContainer(padding: .horizontal, 32) {
            Text("Custom Horizontal Padding: 32")
                .padding(100)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
