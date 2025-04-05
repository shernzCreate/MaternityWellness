import SwiftUI

struct ColorTheme {
    // Primary colors from the app icon
    static let primaryPink = Color(red: 255/255, green: 182/255, blue: 229/255)
    static let primaryLightPink = Color(red: 255/255, green: 213/255, blue: 241/255)
    static let accentYellow = Color(red: 255/255, green: 243/255, blue: 191/255)
    static let textGray = Color(red: 85/255, green: 85/255, blue: 85/255)
    
    // Background gradient
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 255/255, green: 217/255, blue: 243/255),
            Color(red: 255/255, green: 243/255, blue: 220/255)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Button gradient
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [
            primaryPink,
            Color(red: 255/255, green: 201/255, blue: 237/255)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
