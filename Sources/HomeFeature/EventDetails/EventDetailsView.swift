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
            VStack(spacing: 24) {
                // Event banner - placeholder since we don't have an image in the model
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(height: 200)
                    .overlay {
                        VStack {
                            Spacer()
                            Text(self.store.event.categories.first?.name ?? "Event")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 16) {
                    // Event name
                    Text(self.store.event.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)

                    // Organizer
                    HStack {
                        if let photoURL = self.store.event.author.photoURL {
                            AsyncImage(url: photoURL) { phase in
                                switch phase {
                                case .empty:
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                case let .success(image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                case .failure:
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(String(self.store.event.author.fullName?.prefix(1) ?? "?"))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(Color.gray)
                                        }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text(String(self.store.event.author.fullName?.prefix(1) ?? "?"))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.gray)
                                }
                        }

                        Text("Organized by \(self.store.event.author.fullName ?? "Unknown")")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.gray)
                    }

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
                                    // Icon based on category
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

                    Divider()
                        .padding(.vertical, 8)

                    // Event description
                    Text("About Event")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.bottom, 4)

                    Text(self.store.event.description)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.primary)

                    Divider()
                        .padding(.vertical, 8)

                    // Price and Attend button
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Price")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.gray)

                                Text("\(Int(self.store.event.price)) UAH")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color.primary)
                            }

                            Spacer()
                        }

                        Button {
                            send(.attendButtonTapped)
                        } label: {
                            Text("Attend")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }

                    // Map preview
                    self.locationMapPreview
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(self.store.event.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { send(.onAppear) }
    }

    private var locationMapPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.system(size: 18, weight: .bold))

            ZStack {
                // Map placeholder - In a real app, you'd use MapKit here
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 180)
                    .cornerRadius(12)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)

                // Add overlay to open maps when tapped
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
        .padding(.top, 8)
    }

    // Helper function to map category icons to SF Symbols
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

#Preview {
    NavigationStack {
        EventDetailsView(store: Store(initialState: EventDetails.State(event: Event.mock)) {
            EventDetails()
        })
    }
}
