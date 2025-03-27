import APIClient
import Foundation
import SharedModels

extension Components.Schemas.CategoryDto {
    func toDomain() -> EventCategory {
        EventCategory(
            id: self.id,
            name: self.name,
            slug: self.slug,
            icon: self.icon.toDomain(),
            description: self.description
        )
    }
}

extension Components.Schemas.Icon {
    func toDomain() -> CategoryIcon {
        switch self {
        case .party: .party
        case .disco: .disco
        case .competition: .competition
        case .festival: .festival
        case .conference: .conference
        case .workshop: .workshop
        case .meeting: .meeting
        }
    }
}

extension CategoryIcon {
    func toAPI() -> Components.Schemas.Icon {
        switch self {
        case .party: .party
        case .disco: .disco
        case .competition: .competition
        case .festival: .festival
        case .conference: .conference
        case .workshop: .workshop
        case .meeting: .meeting
        }
    }
}

extension CreateCategoryRequest {
    func toAPI() -> Components.Schemas.CreateCategoryDto {
        Components.Schemas.CreateCategoryDto(
            name: self.name,
            slug: self.slug,
            icon: self.icon.toAPI(),
            description: self.description
        )
    }
}

extension UpdateCategoryRequest {
    func toAPI() -> Components.Schemas.UpdateCategoryDto {
        Components.Schemas.UpdateCategoryDto(
            name: self.name,
            slug: self.slug,
            icon: self.icon?.toAPI(),
            description: self.description
        )
    }
}
