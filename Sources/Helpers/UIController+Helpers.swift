import UIKit

private struct NoViewControllerError: Error {}

public extension UIViewController {
    static func getRootViewController() throws -> UIViewController {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first

        guard let rootViewController = window?.rootViewController else {
            throw NoViewControllerError()
        }
        return rootViewController
    }
}
