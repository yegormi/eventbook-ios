import AppFeature
import ComposableArchitecture
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Styleguide
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        guard let clientID = FirebaseApp.app()?.options.clientID else { return true }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Override apple's buggy alerts tintColor not taking effect.
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.accent

        return true
    }

    func application(
        _: UIApplication,
        open url: URL,
        options _: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct EventBookApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let store = Store(initialState: AppReducer.State()) {
        AppReducer()
//            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: self.store)
                .scrollIndicators(.never)
        }
    }
}
