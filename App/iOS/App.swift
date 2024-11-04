import AppFeature
import ComposableArchitecture
import SwiftUI
import Styleguide

@main
struct BankingApp: App {
    let store: StoreOf<AppReducer>
    
    init() {
        // Style navigation bars
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor(Color.neutral800),
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor(Color.neutral800),
        ]
        
        appearance.shadowImage = nil
        appearance.shadowColor = nil

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        self.store = Store(initialState: AppReducer.State()) {
            AppReducer()
                ._printChanges()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: self.store)
                .scrollIndicators(.never)
        }
    }
}
