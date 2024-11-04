import SwiftUI

struct OnFirstAppear: ViewModifier {
    @State private var hasAppeared = false
    let perform: () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            defer { hasAppeared = true }
            guard !self.hasAppeared else { return }
            self.perform()
        }
    }
}

public extension View {
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        self.modifier(OnFirstAppear(perform: perform))
    }
}
