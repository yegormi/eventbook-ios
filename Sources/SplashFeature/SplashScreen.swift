import SwiftUI

public struct SplashScreen: View {
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            Image(.launchScreen)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

public struct SplashScreen_Previews: PreviewProvider {
    public static var previews: some View {
        SplashScreen()
    }
}
