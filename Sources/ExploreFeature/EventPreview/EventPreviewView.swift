import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: EventPreview.self)
public struct EventPreviewView: View {
    @Bindable public var store: StoreOf<EventPreview>

    public init(store: StoreOf<EventPreview>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Event details
                    VStack(alignment: .leading, spacing: 16) {
                        // Event name
                        Text(self.store.event.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.primary)

                        // Date and time
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color.gray)

                            Text(self.store.event.date.formatted(date: .long, time: .shortened))
                                .font(.system(size: 16))
                                .foregroundStyle(Color.gray)
                        }

                        // Location
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(Color.gray)

                            Text(self.store.event.address)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.gray)
                                .multilineTextAlignment(.leading)
                        }

                        // Price
                        HStack(spacing: 8) {
                            Image(systemName: "tag")
                                .foregroundStyle(Color.gray)

                            Text("\(Int(self.store.event.price)) UAH")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.primary)
                        }
                    }

                    // Organizer info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Organizer")
                            .font(.system(size: 18, weight: .semibold))

                        HStack(spacing: 12) {
                            // Organizer avatar
                            CircleAvatarView(
                                model: self.store.event.author,
                                photoURL: self.store.event.author.photoURL,
                                size: 50
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(self.store.event.author.fullName ?? "Unknown")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.primary)

                                Text("Event organizer")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                }
            }

            // View details button (fixed at bottom)
            VStack {
                Divider()

                Button {
                    send(.viewDetailsButtonTapped)
                } label: {
                    Text("View Full Details")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primary(size: .small))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    send(.dismissButtonTapped)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    EventPreviewView(store: Store(initialState: EventPreview.State(event: .mock)) {
        EventPreview()
    })
}
