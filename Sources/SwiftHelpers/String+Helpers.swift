import Foundation

public extension String {
    var isValidEmail: Bool {
        let emailRegex = #/^\S+@\S+\.\S+$/#
        return self.wholeMatch(of: emailRegex) != nil
    }
}
