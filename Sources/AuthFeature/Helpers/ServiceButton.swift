import SwiftUI

public struct ServiceButton: View {
    private let authService: AuthServiceType
    private let action: () -> Void

    public init(
        authService: AuthServiceType,
        action: @escaping () -> Void
    ) {
        self.authService = authService
        self.action = action
    }

    public var body: some View {
        Button {
            self.action()
        } label: {
            HStack {
                self.authService.icon
                    .frame(width: 20, height: 20)
                    .fixedSize()
                Spacer()
                Text("Continue with " + self.authService.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
            }
        }
        .buttonStyle(.service)
    }
}

public enum AuthServiceType {
    case google
    case facebook

    public var title: String {
        switch self {
        case .google:
            "Google"
        case .facebook:
            "Facebook"
        }
    }

    public var icon: Image {
        switch self {
        case .google:
            .init(.google)
        case .facebook:
            .init(.facebook)
        }
    }
}
