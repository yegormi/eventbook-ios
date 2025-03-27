import SwiftUI

public struct ShimmerEffect: Animatable, ViewModifier {
    private let isLoading: Bool

    @State private var isAnimating = false
    private let animation: Animation
    private let gradient: Gradient
    private let angle: Angle
    private let min = -0.5
    private let max = 1.5

    public static let defaultGradient = Gradient(colors: [.clear, .white.opacity(0.8), .clear])
    public static let defaultAnimation = Animation.linear(duration: 0.7).repeatForever(autoreverses: false)
    public static let defaultAngle = Angle.degrees(0.0)

    public init(
        isLoading: Bool,
        gradient: Gradient = Self.defaultGradient,
        animation: Animation = Self.defaultAnimation,
        angle: Angle = Self.defaultAngle
    ) {
        self.isLoading = isLoading
        self.gradient = gradient
        self.animation = animation
        self.angle = angle
    }

    public func body(content: Content) -> some View {
        if self.isLoading {
            content.overlay {
                self.shimmerView
                    .mask(content)
            }
        } else {
            content
        }
    }

    var startPoint: UnitPoint {
        self.isAnimating ? UnitPoint(x: 1, y: 1) : UnitPoint(x: self.min, y: self.min)
    }

    var endPoint: UnitPoint {
        self.isAnimating ? UnitPoint(x: self.max, y: self.max) : UnitPoint(x: 0, y: 0)
    }

    var shimmerView: some View {
        LinearGradient(gradient: self.gradient, startPoint: self.startPoint, endPoint: self.endPoint)
            .rotationEffect(self.angle)
            .scaleEffect(1.5)
            .clipped()
            .animation(self.animation, value: self.isAnimating)
            .onAppear {
                guard self.isLoading else { return }
                self.isAnimating = true
            }
            .onChange(of: self.isLoading) {
                self.isAnimating.toggle()
            }
    }
}

public extension View {
    func shimmerEffect(
        isLoading: Bool = true,
        gradient: Gradient = ShimmerEffect.defaultGradient,
        animation: Animation = ShimmerEffect.defaultAnimation,
        angle: Angle = ShimmerEffect.defaultAngle
    ) -> some View {
        self.modifier(
            ShimmerEffect(
                isLoading: isLoading,
                gradient: gradient,
                animation: animation,
                angle: angle
            )
        )
    }
}
