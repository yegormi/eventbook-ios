import AppFeature
import AppTrackingTransparency
import ComposableArchitecture
import FacebookCore
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import OSLog
import Styleguide
import SwiftUI

private let logger = Logger(subsystem: "iOS", category: "App")

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        FirebaseApp.configure()

        guard let clientID = FirebaseApp.app()?.options.clientID else { return true }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Override apple's buggy alerts tintColor not taking effect.
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.accent

        self.requireAppTrackingTransparency()

        return true
    }

    func requireAppTrackingTransparency() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    logger.info("Tracking permissions are allowed. Analytics are initialized.")
                case .notDetermined:
                    logger.info("Tracking permissions are not determined.")
                case .restricted:
                    logger.info("Tracking permissions are restricted.")
                case .denied:
                    logger.info("Tracking permissions are denied.")
                @unknown default:
                    logger.info("Tracking permissions have an unknown status.")
                }
            }
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let facebookHandle = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

        let googleHandle = GIDSignIn.sharedInstance.handle(url)

        return facebookHandle || googleHandle
    }
}

@main
struct EventBookApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: self.store)
                .scrollIndicators(.never)
        }
    }
}
