import SwiftUI

/// Centralized Theme system for the application.
/// Defines all colors, fonts, and styling constants to ensure a coherent "Dark Glassy" aesthetic.
struct Theme {
    struct Colors {
        // MARK: - Backgrounds
        // Base background for main windows (dark, slightly blue-ish charcoal for depth)
        static let background = Color(red: 22/255, green: 22/255, blue: 24/255)
        
        // Secondary background for sidebars or distinct sections
        static let secondaryBackground = Color(red: 28/255, green: 28/255, blue: 32/255)
        
        // Surface color for cards, inputs, and floating elements
        static let surface = Color(white: 0.15)
        static let surfaceHighlight = Color(white: 0.20)
        
        // MARK: - Text
        static let textPrimary = Color.white.opacity(0.95)
        static let textSecondary = Color.white.opacity(0.65)
        static let textTertiary = Color.white.opacity(0.40)
        
        // MARK: - Accents
        // Premium blue accent for active states, primary buttons, and highlights
        static let accent = Color(red: 58/255, green: 110/255, blue: 245/255) // Vibrant Blue
        static let accentHover = Color(red: 70/255, green: 125/255, blue: 255/255)
        
        // Semantic overrides
        static let destructive = Color(red: 1.0, green: 0.27, blue: 0.27)
        static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        
        // MARK: - Borders & Separators
        static let separator = Color.white.opacity(0.1)
        static let border = Color.white.opacity(0.15)
    }
    
    struct Layout {
        static let cornerRadius: CGFloat = 12.0
        static let smallCornerRadius: CGFloat = 8.0
        static let padding: CGFloat = 16.0
        static let smallPadding: CGFloat = 8.0
    }
    
    struct Fonts {
        // Using System rounded for a friendly yet modern tech feel (like Linear/Raycast)
        static func display(size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        
        static func body(size: CGFloat) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
    }
}

// MARK: - SwiftUI Extensions
extension View {
    /// Applies the standard corner radius
    func standardCornerRadius() -> some View {
        self.cornerRadius(Theme.Layout.cornerRadius)
    }
    
    /// Applies a standard subtle border
    func standardBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                .stroke(Theme.Colors.border, lineWidth: 1)
        )
    }
}
