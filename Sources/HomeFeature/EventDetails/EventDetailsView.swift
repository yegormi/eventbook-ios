import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: EventDetails.self)
public struct EventDetailsView: View {
    @Bindable public var store: StoreOf<EventDetails>

    public init(store: StoreOf<EventDetails>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Event details
                self.eventDetails

                // Similar events section
                if !self.store.similarEvents.isEmpty {
                    Divider()
                        .padding(.vertical, 16)

                    self.similarEventsSection
                }

                // Reviews section
                Divider()
                    .padding(.vertical, 16)

                self.reviewsSection
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(self.store.event.name)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .safeAreaInset(edge: .bottom) {
            self.bottomControls
        }
        .sheet(
            item: self.$store.scope(
                state: \.destination?.addReview,
                action: \.destination.addReview
            )
        ) { store in
            NavigationStack {
                AddReviewView(store: store)
            }
        }
        .onAppear { send(.onAppear) }
    }

    private var bottomControls: some View {
        VStack {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Price")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)

                    Text("\(Int(self.store.event.price)) UAH")
                        .font(.system(size: 24, weight: .bold))
                }

                Spacer()

                Button("Attend") {
                    send(.attendButtonTapped)
                }
                .buttonStyle(.primary(size: .small))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Event Header

    private var eventHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image / color
            Rectangle()
                .fill(Color.black)
                .aspectRatio(16 / 9, contentMode: .fill)
                .frame(height: 200)
                .overlay {
                    // Category badge
                    if let categoryName = self.store.event.categories.first?.name {
                        VStack {
                            Spacer()
                            Text(categoryName)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding([.bottom, .leading], 16)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
        }
    }

    // MARK: - Event Details

    private var eventDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Event name
            Text(self.store.event.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.primary)
                .padding(.top, 16)

            // Event brief description
            Text("Some disco") // This would be from your model
                .font(.system(size: 16))
                .foregroundStyle(Color.gray)

            // Event date and time
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.gray)

                Text(self.store.event.date.formatted(date: .long, time: .shortened))
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
            }

            // Event location
            Button {
                send(.showLocationButtonTapped)
            } label: {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(Color.blue)

                    Text(self.store.event.address)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.blue)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
            }
            .buttonStyle(.plain)

            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(self.store.event.categories, id: \.id) { category in
                        HStack(spacing: 4) {
                            Image(systemName: self.iconForCategory(category.icon))
                                .font(.system(size: 12))
                                .foregroundStyle(Color.primary)

                            Text(category.name)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .foregroundStyle(Color.primary)
                        .cornerRadius(16)
                    }
                }
            }

            // Event description
            VStack(alignment: .leading, spacing: 8) {
                Text("About Event")
                    .font(.system(size: 18, weight: .bold))

                HTMLText(htmlContent: self.store.event.description)
                    .frame(maxWidth: .infinity, alignment: .leading)

//                if let htmlText = Text.html(
//                    self.store.event.description,
//                    font: .body,
//                    textColor: .primary,
//                    linkColor: .blue
//                ) {
//                    htmlText
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                } else {
//                    HTMLText(htmlContent: self.store.event.description)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
            }
            .padding(.top, 8)

            // Location map
            VStack(alignment: .leading, spacing: 12) {
                Text("Location")
                    .font(.system(size: 18, weight: .bold))

                ZStack {
                    // Map placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 180)
                        .cornerRadius(12)

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)

                    Button {
                        send(.showLocationButtonTapped)
                    } label: {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 180)
                    }
                }

                Text(self.store.event.address)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Similar Events Section

    private var similarEventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Similar events")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)

            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(self.store.similarEvents) { event in
                        Button {
                            send(.similarEventTapped(event))
                        } label: {
                            SimilarEventCard(event: event)
                                .frame(width: 280)
                        }
                        .buttonStyle(.tappable)
                    }

                    if self.store.isLoadingSimilarEvents {
                        ProgressView()
                            .frame(width: 50)
                    } else if self.store.similarEventsPageSettings.hasMorePages {
                        Button {
                            send(.loadMoreSimilarEvents)
                        } label: {
                            Text("Load More")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 100, height: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reviews")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                Button {
                    send(.addReviewTapped)
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Review")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 16)

            if self.store.reviews.isEmpty && !self.store.isLoadingReviews {
                Text("No reviews yet. Be the first to review!")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(self.store.reviews) { review in
                    self.reviewCard(review)

                    if review.id != self.store.reviews.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }

                if self.store.isLoadingReviews {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if self.store.reviewsPageSettings.hasMorePages {
                    Button {
                        send(.loadMoreReviews)
                    } label: {
                        Text("Load More Reviews")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
        }
    }

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CircleAvatarView(
                    model: review.author,
                    photoURL: review.author.photoURL,
                    size: 40
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(review.author.fullName ?? "Anonymous")
                        .font(.system(size: 16, weight: .medium))

                    Text(review.title)
                        .font(.system(size: 16, weight: .bold))
                }

                Spacer()

                Text(review.createdAt.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray)
            }

            // Review content
            Text(review.content)
                .font(.system(size: 16))
                .foregroundStyle(Color.primary)

            // Rating stars
            HStack {
                ForEach(1 ... 5, id: \.self) { index in
                    Image(systemName: index <= review.rating ? "star.fill" : "star")
                        .foregroundStyle(index <= review.rating ? Color.yellow : Color.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Helper Methods

    private func iconForCategory(_ icon: CategoryIcon) -> String {
        switch icon {
        case .party:
            "party.popper.fill"
        case .disco:
            "music.note.list"
        case .competition:
            "trophy.fill"
        case .festival:
            "sparkles"
        case .conference:
            "person.3.fill"
        case .workshop:
            "hammer.fill"
        case .meeting:
            "calendar.badge.clock"
        }
    }
}

// MARK: - Supporting Views

struct SimilarEventCard: View {
    let event: Event

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16 / 9, contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Category tag
                    if let category = event.categories.first {
                        HStack(spacing: 4) {
                            Image(systemName: self.categoryIcon(category.icon))
                                .font(.system(size: 12))
                            Text(category.name)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                        .padding(8)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(self.event.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)

                    Text(self.event.date.formatted(date: .numeric, time: .omitted))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }

                HStack {
                    Spacer()
                    Text("Learn more")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    private func categoryIcon(_ icon: CategoryIcon) -> String {
        switch icon {
        case .party: "party.popper.fill"
        case .disco: "music.note.list"
        case .competition: "trophy.fill"
        case .festival: "sparkles"
        case .conference: "person.3.fill"
        case .workshop: "hammer.fill"
        case .meeting: "calendar.badge.clock"
        }
    }
}

// MARK: - Add Review View

#Preview {
    NavigationStack {
        EventDetailsView(store: Store(initialState: EventDetails.State(event: Event.mock)) {
            EventDetails()
        })
    }
}
