import SwiftUI
import SharedModels
import Styleguide

struct AppCardCell: View {
    let card: AppCard
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.neutral800)
                .frame(width: 48, height: 32)
                .overlay(alignment: .bottomTrailing) {
                    Text(card.cardLast4)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 10, weight: .bold))
                        .padding(6)
                }
            Text(card.cardName)
                .foregroundStyle(Color.neutral900)
                .font(.labelLarge)
        }
    }
}
