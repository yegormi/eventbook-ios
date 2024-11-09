import SwiftUI

public struct FullScreenLoadingModifier: ViewModifier {
    let isLoading: Bool

    public func body(content: Content) -> some View {
        ZStack {
            content

            if self.isLoading {
                Color.black
                    .opacity(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .scaleEffect(CGSize(width: 2.0, height: 2.0))
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}

public extension View {
    func isLoading(_ isLoading: Bool) -> some View {
        self.modifier(FullScreenLoadingModifier(isLoading: isLoading))
    }
}

#Preview {
    VStack {
        Text("Hello")
    }
    .isLoading(true)
}
