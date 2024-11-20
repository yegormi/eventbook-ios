import Dependencies
import DependenciesAdditions
import DependenciesMacros
import SharedModels
import UIKit

extension AppearanceClient: DependencyKey {
    public static let liveValue = Self(
        setAppearance: { appearance in
            @Dependency(\.userDefaults) var userDefaults
            userDefaults.set(appearance.rawValue, forKey: "app.appearance")
            await applyAppearance(appearance)
        },
        currentAppearance: {
            @Dependency(\.userDefaults) var userDefaults
            return getSavedAppearance(userDefaults)
        },
        configure: {
            @Dependency(\.userDefaults) var userDefaults
            let appearance = getSavedAppearance(userDefaults)
            await applyAppearance(appearance)
        }
    )
}

// MARK: - Private Helpers

private func getSavedAppearance(_ userDefaults: UserDefaults.Dependency) -> PhoneAppearance {
    if
        let savedAppearance = userDefaults.string(forKey: "app.appearance"),
        let appearance = PhoneAppearance(rawValue: savedAppearance)
    {
        return appearance
    }
    return .system
}

@MainActor
private func applyAppearance(_ appearance: PhoneAppearance) async {
    let scenes = UIApplication.shared.connectedScenes
    let windowScenes = scenes.first as? UIWindowScene
    let window = windowScenes?.windows.first
    window?.overrideUserInterfaceStyle = appearance.toUI()
}

public extension PhoneAppearance {
    func toUI() -> UIUserInterfaceStyle {
        switch self {
        case .system:
            .unspecified
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
