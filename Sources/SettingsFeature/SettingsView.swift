import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Settings.self)
public struct SettingsView: View {
    @Bindable public var store: StoreOf<Settings>

    public init(store: StoreOf<Settings>) {
        self.store = store
    }

    public var body: some View {
        PagerView([.general, .account, .security], selectedTab: self.$store.tab) {
            SettingsGeneralView(
                store: self.store.scope(
                    state: \.general,
                    action: \.general
                )
            )
            .tag(Settings.State.Tab.general)

            SettingsAccountView(
                store: self.store.scope(
                    state: \.account,
                    action: \.account
                )
            )
            .tag(Settings.State.Tab.account)

            EmptyTabView()
                .tag(Settings.State.Tab.security)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView(store: Store(initialState: Settings.State()) {
        Settings()
    })
}

extension Settings.State.Tab: PagerViewTab {
    public var title: LocalizedStringResource {
        switch self {
        case .account:
            "Account"
        case .general:
            "General"
        case .security:
            "Security"
        }
    }
}
