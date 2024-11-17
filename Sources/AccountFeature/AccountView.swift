import ComposableArchitecture
import Foundation
import SettingsFeature
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Account.self)
public struct AccountView: View {
    @Bindable public var store: StoreOf<Account>

    public init(store: StoreOf<Account>) {
        self.store = store

        // Sets the background color of the Picker
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.neutral900).withAlphaComponent(0.1)
        // Disappears the divider
        UISegmentedControl.appearance().setDividerImage(
            UIImage(),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )
        // Changes the color for the selected item
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.purple400)
        // Changes the text color for the selected item
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                self.avatarCell(for: self.store.user)

                Picker("Sections", selection: self.$store.tab) {
                    ForEach(Account.State.Tab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                self.contentView(for: self.store.tab)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentMargins(.all, 16, for: .scrollContent)
        .onAppear {
            send(.onAppear)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    send(.settingsButtonTapped)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .padding(13)
                        .clipShape(Circle())
                }
            }
        }
        .navigationDestination(
            item: self.$store.scope(state: \.destination?.settings, action: \.destination.settings)
        ) { store in
            SettingsView(store: store)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func avatarCell(for user: SharedModels.User) -> some View {
        HStack(spacing: 12) {
            self.userAvatar(for: user)
                .frame(width: 70, height: 70)
            VStack(alignment: .leading, spacing: 5) {
                Text(user.fullName ?? "No username provided")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(user.email ?? "No email registered")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.neutral500)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func contentView(for tab: Account.State.Tab) -> some View {
        switch tab {
        case .events:
            self.eventsContent()
        case .tickets:
            self.ticketsContent()
        case .reviews:
            self.reviewsContent()
        }
    }

    @ViewBuilder
    private func eventsContent() -> some View {
        VStack {
            Text("My events")
                .font(.headlineSmall)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func ticketsContent() -> some View {
        VStack {
            Text("My tickets")
                .font(.headlineSmall)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func reviewsContent() -> some View {
        VStack {
            Text("My reviews")
                .font(.headlineSmall)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func userAvatar(for user: SharedModels.User) -> some View {
        if let pictureURL = user.photoURL {
            AsyncImage(url: pictureURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } placeholder: {
                self.placeholderAvatar(for: user)
            }
        } else {
            self.placeholderAvatar(for: user)
        }
    }

    private func placeholderAvatar(for user: User) -> some View {
        Circle()
            .foregroundStyle(Color.neutral200)
            .overlay {
                Text(user.fullName?.first?.uppercased() ?? "")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.neutral500)
            }
    }
}

#Preview {
    AccountView(store: Store(initialState: Account.State()) {
        Account()
    })
}
