import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftHelpers
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: Home.self)
public struct HomeView: View {
    @Bindable public var store: StoreOf<Home>

    public init(store: StoreOf<Home>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                self.searchBar

                if !self.store.events.isEmpty {
                    self.eventsList
                } else if !self.store.isLoading {
                    self.emptyStateView(
                        title: "No events",
                        message: "Future events will appear here."
                    )
                } else {
                    self.loadingView
                }
            }
            .transition(.opacity)
            .animation(.default, value: self.store.events)
        }
        .contentMargins(16, for: .scrollContent)
        .refreshable {
            await send(.refreshEvents).finish()
        }
        .onFirstAppear {
            send(.onFirstAppear)
        }
        .onAppear {
            send(.onAppear)
        }
    }

    private var loadingView: some View {
        LazyVStack(spacing: 12) {
            ForEach(0 ..< 8, id: \.self) { _ in
                LoadingEventCard()
            }
        }
    }

    private func emptyStateView(title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "menucard")
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
        .frame(minHeight: 300)
        .padding(.top, 32)
    }

    private var eventsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(self.store.events) { event in
                Button {
                    send(.eventTapped(event))
                } label: {
                    EventCard(event: event)
                        .onAppear { send(.eventAppeared(event.id)) }
                }
                .buttonStyle(.tappable)
            }

            if self.store.isLoading {
                ProgressView()
                    .padding(16)
            }
        }
    }

    private var searchBar: some View {
        CardContainer {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)

                TextField("Search", text: self.$store.searchQuery)
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
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
