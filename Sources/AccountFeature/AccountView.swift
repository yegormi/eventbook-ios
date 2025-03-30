import ComposableArchitecture
import EventDetailsFeature
import Foundation
import SettingsFeature
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

// swiftlint:disable file_length
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
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.accentColor)
        // Changes the text color for the selected item
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                self.avatarCell(for: self.store.user)

                self.searchBar

                Picker("Sections", selection: self.$store.tab) {
                    ForEach(Account.Tab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                self.contentView(for: self.store.tab)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentMargins(.all, 16, for: .scrollContent)
        .refreshable {
            await send(.refreshContent(self.store.tab)).finish()
        }
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
        .navigationDestination(
            item: self.$store.scope(state: \.destination?.eventDetails, action: \.destination.eventDetails)
        ) { store in
            EventDetailsView(store: store)
        }
    }

    private var searchBar: some View {
        CardContainer {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)

                TextField("Search \(self.store.tab.title.lowercased())", text: self.$store.searchQuery)
                    .foregroundStyle(Color.primary)

                if !self.store.searchQuery.isEmpty {
                    Button {
                        send(.searchCleared)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
        }
    }

    private func avatarCell(for user: SharedModels.User) -> some View {
        HStack(spacing: 12) {
            CircleAvatarView(
                model: user,
                photoURL: user.photoURL,
                size: 70
            )
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
    private func contentView(for tab: Account.Tab) -> some View {
        switch tab {
        case .events:
            self.eventsContent()
        case .tickets:
            self.ticketsContent()
        case .reviews:
            self.reviewsContent()
        }
    }

    // MARK: - Events Content

    @ViewBuilder
    private func eventsContent() -> some View {
        VStack(spacing: 0) {
            if !self.store.events.isEmpty {
                self.eventsList
            } else if !(self.store.isLoading[.events] ?? false) {
                if !self.store.searchQuery.isEmpty {
                    self.emptyStateView(
                        title: "No matching events",
                        message: "Try adjusting your search criteria.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    self.emptyStateView(
                        title: "No events created",
                        message: "Events you create will appear here.",
                        systemImage: "calendar.badge.plus"
                    )
                }
            } else {
                self.loadingView
            }
        }
        .transition(.opacity)
        .animation(.default, value: self.store.events)
    }

    private var eventsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(self.store.events) { event in
                Button {
                    send(.itemTapped(.events, event.id, event))
                } label: {
                    EventCard(event: event)
                        .onAppear { send(.itemAppeared(.events, event.id)) }
                }
                .buttonStyle(.tappable)
            }

            if self.store.isLoading[.events] ?? false {
                ProgressView()
                    .padding(16)
            }
        }
    }

    // MARK: - Tickets Content

    @ViewBuilder
    private func ticketsContent() -> some View {
        VStack(spacing: 0) {
            if !self.store.tickets.isEmpty {
                self.ticketsList
            } else if !(self.store.isLoading[.tickets] ?? false) {
                if !self.store.searchQuery.isEmpty {
                    self.emptyStateView(
                        title: "No matching tickets",
                        message: "Try adjusting your search criteria.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    self.emptyStateView(
                        title: "No tickets purchased",
                        message: "Tickets for events you attend will appear here.",
                        systemImage: "ticket"
                    )
                }
            } else {
                self.loadingView
            }
        }
        .transition(.opacity)
        .animation(.default, value: self.store.tickets)
    }

    private var ticketsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(self.store.tickets) { ticket in
                Button {
                    send(.itemTapped(.tickets, ticket.id, ticket.event))
                } label: {
                    TicketCard(ticket: ticket)
                        .onAppear { send(.itemAppeared(.tickets, ticket.id)) }
                }
                .buttonStyle(.tappable)
            }

            if self.store.isLoading[.tickets] ?? false {
                ProgressView()
                    .padding(16)
            }
        }
    }

    // MARK: - Reviews Content

    @ViewBuilder
    private func reviewsContent() -> some View {
        VStack(spacing: 0) {
            if !self.store.reviews.isEmpty {
                self.reviewsList
            } else if !(self.store.isLoading[.reviews] ?? false) {
                if !self.store.searchQuery.isEmpty {
                    self.emptyStateView(
                        title: "No matching reviews",
                        message: "Try adjusting your search criteria.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    self.emptyStateView(
                        title: "No reviews written",
                        message: "Reviews you write for events will appear here.",
                        systemImage: "star.bubble"
                    )
                }
            } else {
                self.loadingView
            }
        }
        .transition(.opacity)
        .animation(.default, value: self.store.reviews)
    }

    private var reviewsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(self.store.reviews) { review in
                Button {
                    send(.itemTapped(.reviews, review.id, review.event))
                } label: {
                    ReviewCard(review: review)
                        .onAppear { send(.itemAppeared(.reviews, review.id)) }
                }
                .buttonStyle(.tappable)
            }

            if self.store.isLoading[.reviews] ?? false {
                ProgressView()
                    .padding(16)
            }
        }
    }

    // MARK: - Helper Views

    private var loadingView: some View {
        LazyVStack(spacing: 12) {
            ForEach(0 ..< 8, id: \.self) { _ in
                LoadingEventCard()
            }
        }
    }

    private func emptyStateView(title: String, message: String, systemImage: String) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(Color.neutral400)
                .padding(.bottom, 8)

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.neutral500)

            Text(message)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.neutral500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding(.top, 32)
    }
}

// MARK: - Supporting Views

struct TicketCard: View {
    let ticket: Ticket

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Event name
                Text(self.ticket.event.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)

                // Ticket details
                HStack {
                    // Date
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                        Text(self.ticket.event.date.formatted(date: .numeric, time: .omitted))
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                    }

                    Spacer()

                    // Price
                    Text("\(Int(self.ticket.event.price)) UAH")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }

                // Status
                HStack {
                    // Event status indicator
                    let isUpcoming = self.ticket.event.date > Date()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isUpcoming ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)

                    Text(isUpcoming ? "Upcoming" : "Past")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)

                    Spacer()

                    Text("View Event")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

struct ReviewCard: View {
    let review: Review

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                // Event name
                HStack {
                    Text(self.review.event.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)

                    Spacer()

                    Text(self.review.createdAt.formatted(date: .numeric, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                }

                // Review title
                Text(self.review.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primary)

                // Rating
                HStack {
                    ForEach(1 ... 5, id: \.self) { index in
                        Image(systemName: index <= self.review.rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundStyle(index <= self.review.rating ? Color.yellow : Color.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    AccountView(store: Store(initialState: Account.State()) {
        Account()
    })
}

// swiftlint:enable file_length
