import Foundation

public protocol FullNameRepresentable {
    var personFullName: String { get }
}

public extension FullNameRepresentable {
    var initials: String {
        let initial = personFullName.prefix(1)
        return "\(initial)".uppercased()
    }
}

extension User: FullNameRepresentable {
    public var personFullName: String { self.fullName ?? "Anonymous" }
}
