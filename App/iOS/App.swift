import AppFeature
import ComposableArchitecture
import FirebaseCore
import FirebaseAuth
import Styleguide
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Override apple's buggy alerts tintColor not taking effect.
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.accent

        return true
    }
}

@main
struct EventBookApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let store = Store(initialState: AppReducer.State()) {
        AppReducer()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: self.store)
                .scrollIndicators(.never)
        }
    }
}
