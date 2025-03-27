import SharedModels
import Styleguide
import SwiftUI
import SwiftUIHelpers

struct EventCard: View {
    let event: Event

    var body: some View {
        CardContainer {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.event.name)
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text(self.formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }

                Spacer(minLength: 8)

                HStack(spacing: 8) {
                    Text("\(Int(self.event.price)) UAH")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)

                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                }
            }
        }
    }

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d'th', yyyy"
        return dateFormatter.string(from: self.event.date)
    }
}
