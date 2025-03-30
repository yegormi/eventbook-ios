import Foundation

public enum CategoryIcon: String, Codable, CaseIterable, Sendable {
    case party
    case disco
    case competition
    case festival
    case conference
    case workshop
    case meeting
}

public extension CategoryIcon {
    var sfSymbolName: String {
        switch self {
        case .party: "party.popper.fill"
        case .disco: "music.note.list"
        case .competition: "trophy.fill"
        case .festival: "sparkles"
        case .conference: "person.3.fill"
        case .workshop: "hammer.fill"
        case .meeting: "calendar.badge.clock"
        }
    }
}
