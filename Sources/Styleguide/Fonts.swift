import SwiftUI

public extension Font {
    static var headlineSmall: Self {
        .system(size: 17, weight: .semibold)
    }
    
    static var headlineMedium: Self {
        .system(size: 28, weight: .bold)
    }
    
    static var headlineLarge: Self {
        .system(size: 34, weight: .bold)
    }
    
    static var labelMedium: Self {
        .system(size: 13, weight: .semibold)
    }
    
    static var labelLarge: Self {
        .system(size: 15, weight: .semibold)
    }
    
    static var titleMedium: Self {
        .system(size: 16, weight: .semibold)
    }
}
