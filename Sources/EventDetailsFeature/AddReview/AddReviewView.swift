import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

@ViewAction(for: AddReview.self)
struct AddReviewView: View {
    @Bindable var store: StoreOf<AddReview>

    var body: some View {
        VStack(spacing: 20) {
            Text("Rate your experience")
                .font(.title2)
                .fontWeight(.bold)

            // Star rating selector
            HStack(spacing: 12) {
                ForEach(1 ... 5, id: \.self) { rating in
                    Button {
                        self.store.rating = rating
                    } label: {
                        Image(systemName: rating <= self.store.rating ? "star.fill" : "star")
                            .font(.system(size: 30))
                            .foregroundStyle(rating <= self.store.rating ? .yellow : .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            // Title text area
            TextField("Title", text: self.$store.title, axis: .vertical)
                .padding()
                .frame(minHeight: 30, alignment: .topLeading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

            // Review text area
            TextField("Write your review here...", text: self.$store.content, axis: .vertical)
                .padding()
                .frame(minHeight: 150, alignment: .topLeading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

            Spacer()

            // Submit button
            Button("Submit Review") {
                send(.submitButtonTapped)
            }
            .buttonStyle(.primary(size: .fullWidth))
            .padding()
        }
        .padding()
        .navigationTitle("Add Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    send(.cancelButtonTapped)
                }
            }
        }
    }
}
