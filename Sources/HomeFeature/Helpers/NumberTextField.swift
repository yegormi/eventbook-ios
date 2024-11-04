import SwiftUI

struct NumberTextField: View {
    @Binding var value: Decimal?
    let placeholder: String
    let maxLength: Int
    let decimalPlacesLimit: Int
    
    let localizedSeparator = NumberFormatter().decimalSeparator!
    @State private var text: String = ""
    
    
    var body: some View {
        TextField(placeholder, text: $text)
            .fixedSize(horizontal: true, vertical: false)
            .keyboardType(.decimalPad)
            .onChange(of: text) { newValue in
                let formattedValue = formatInput(newValue)
                self.text = formattedValue
                self.value = Decimal(string: formattedValue.filter { "0123456789\(localizedSeparator)".contains($0) })
            }
            .onAppear {
                if let value = value {
                    text = formatDecimal(value)
                }
            }
            .onChange(of: value) { newValue in
                if let newValue = newValue {
                    text = formatDecimal(newValue)
                } else {
                    text = ""
                }
            }
    }
    
    private func formatInput(_ input: String) -> String {
        // Allow only numbers and decimal separators
        var filtered = input.filter { "0123456789., ".contains($0) }
        
        // Ensure only one decimal separator is allowed
        if filtered.filter({ String($0) == localizedSeparator }).count > 1 {
            filtered.removeLast()
        }
        
        // Split on the decimal separator
        let parts = filtered.split(separator: self.localizedSeparator, maxSplits: 1, omittingEmptySubsequences: false)
        
        // Limit the number of decimal places
        if parts.count > 1, parts[1].count > decimalPlacesLimit {
            filtered = "\(parts[0]).\(parts[1].prefix(decimalPlacesLimit))"
        }
        
        return String(filtered.prefix(maxLength))
    }
    
    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalPlacesLimit
        formatter.usesGroupingSeparator = true
        return formatter.string(from: value as NSDecimalNumber) ?? ""
    }
}

