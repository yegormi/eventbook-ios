import Styleguide
import SwiftUI

public protocol PagerViewTab: Hashable {
    var title: LocalizedStringResource { get }
}

public struct PagerView<Tab: PagerViewTab, Content: View>: View {
    let tabs: [Tab]
    @Binding var selectedTab: Tab
    let content: () -> Content

    public init(
        _ tabs: [Tab],
        selectedTab: Binding<Tab>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.tabs = tabs
        self._selectedTab = selectedTab
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                ForEach(self.tabs, id: \.hashValue) { tab in
                    Button(String(localized: tab.title)) {
                        withAnimation(.spring) {
                            self.selectedTab = tab
                        }
                    }
                    .buttonStyle(
                        .tabButton(
                            isActive: self.selectedTab == tab,
                            size: .fullWidth
                        )
                    )
                }
                Spacer()
            }
            .padding(.leading, 12)
            .padding(.bottom, 12)

            TabView(selection: self.$selectedTab.animation(.spring)) {
                self.content()
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}
