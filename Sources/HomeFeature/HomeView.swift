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
        VStack(spacing: 0) {
            self.searchBar

            if self.store.isLoading && self.store.events.isEmpty {
                ProgressView()
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(self.store.events) { event in
                            EventRow(event: event)
                                .onTapGesture {
                                    send(.eventTapped(event))
                                }
                        }
                    }

                    // Pagination controls
                    HStack {
                        Button(action: {
                            if self.store.currentPage > 1 {
                                send(.loadPage(self.store.currentPage - 1))
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.primary)
                        }
                        .disabled(self.store.currentPage <= 1)
                        .opacity(self.store.currentPage <= 1 ? 0.5 : 1)

                        Text("\(self.store.currentPage)")
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 8)

                        Button(action: {
                            send(.loadPage(self.store.currentPage + 1))
                        }) {
                            Text("\(self.store.currentPage + 1)")
                                .foregroundStyle(Color.primary)
                        }
                        .opacity(self.store.currentPage == 2 ? 0.5 : 1)
                        .disabled(self.store.currentPage == 2)

                        Button(action: {
                            if self.store.currentPage < self.store.totalPages {
                                send(.loadPage(self.store.currentPage + 1))
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.primary)
                        }
                        .disabled(self.store.currentPage >= self.store.totalPages)
                        .opacity(self.store.currentPage >= self.store.totalPages ? 0.5 : 1)
                    }
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await send(.refreshEvents).finish()
                }
            }
        }
        .onFirstAppear {
            send(.onFirstAppear)
        }
        .onAppear {
            send(.onAppear)
        }
    }

    private var searchBar: some View {
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
        .padding(10)
        .background(Color.textFieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct EventRow: View {
    let event: Event

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(self.event.name)
                    .font(.headline)
                    .foregroundStyle(Color.primary)

                Text(self.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("\(Int(self.event.price)) UAH")
                    .font(.headline)
                    .foregroundStyle(Color.primary)

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal)
        .background(Color.primary.colorInvert())
        .contentShape(Rectangle())
    }

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d'th', yyyy"
        return dateFormatter.string(from: self.event.date)
    }
}

#Preview {
    HomeView(store: Store(initialState: Home.State()) {
        Home()
    })
}
