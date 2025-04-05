import SwiftUI

struct ColorTheme {
    // Primary colors from the app icon - updated to match the pink-yellow gradient
    static let primaryPink = Color(hex: "FF9494") // Matches the pink in app icon
    static let primaryLightPink = Color(hex: "FFB6C1")
    static let accentYellow = Color(hex: "FFC371") // Matches the yellow in app icon
    static let textGray = Color(red: 85/255, green: 85/255, blue: 85/255)
    
    // Background gradient matching app icon
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "FF9494").opacity(0.2),  // Light pink
            Color(hex: "FFC371").opacity(0.2)   // Light yellow
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Button gradient matching app icon
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [
            primaryPink,
            accentYellow
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Card gradient for highlighting
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            primaryPink.opacity(0.8),
            accentYellow.opacity(0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
