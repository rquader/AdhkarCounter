import AppKit
import SwiftUI

/// A small, explicit theme system tuned for calm utility UI.
///
/// Design intent:
/// - Accent is used sparingly (numeral, progress ring, key state) never as a
///   background.
/// - Surfaces lean on system materials/background so the widget feels native in
///   both light and dark modes.
/// - Palettes are semantic; views should not reach for raw colors.
enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case naturalGreen
    case sepiaSand
    case forestMoss
    case oceanBlue

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .naturalGreen: return "Natural Green"
        case .sepiaSand: return "Sepia Sand"
        case .forestMoss: return "Forest Moss"
        case .oceanBlue: return "Ocean Blue"
        }
    }

    var palette: ThemePalette {
        switch self {
        case .naturalGreen:
            return ThemePalette(
                accent: Color(red: 0.16, green: 0.55, blue: 0.38),
                tint: Color(red: 0.16, green: 0.55, blue: 0.38).opacity(0.06),
                stroke: Color.primary.opacity(0.08),
                shadow: Color.black.opacity(DesignTokens.Elevation.shadowOpacity),
                usesSystemSurface: true
            )
        case .sepiaSand:
            return ThemePalette(
                accent: Color(red: 0.52, green: 0.38, blue: 0.22),
                tint: Color(red: 0.62, green: 0.48, blue: 0.30).opacity(0.12),
                stroke: Color.black.opacity(0.10),
                shadow: Color.black.opacity(0.14),
                usesSystemSurface: false,
                warmSurface: LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.88),
                        Color(red: 0.96, green: 0.92, blue: 0.84)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .forestMoss:
            return ThemePalette(
                accent: Color(red: 0.18, green: 0.45, blue: 0.30),
                tint: Color(red: 0.18, green: 0.45, blue: 0.30).opacity(0.07),
                stroke: Color.primary.opacity(0.08),
                shadow: Color.black.opacity(DesignTokens.Elevation.shadowOpacity),
                usesSystemSurface: true
            )
        case .oceanBlue:
            return ThemePalette(
                accent: Color(red: 0.18, green: 0.45, blue: 0.72),
                tint: Color(red: 0.18, green: 0.45, blue: 0.72).opacity(0.06),
                stroke: Color.primary.opacity(0.08),
                shadow: Color.black.opacity(DesignTokens.Elevation.shadowOpacity),
                usesSystemSurface: true
            )
        }
    }
}

/// Semantic surface colors a view composes with. Prefer these over literals.
struct ThemePalette {
    /// The dominant accent: used sparingly for the numeral, ring stroke and key state.
    let accent: Color
    /// A very light accent tint applied behind or within the widget for warmth.
    let tint: Color
    /// Hairline border color around the surface.
    let stroke: Color
    /// Elevation shadow color.
    let shadow: Color
    /// Whether the theme blends with system materials (`windowBackgroundColor`,
    /// `.regularMaterial`) or uses its own warm surface paint.
    let usesSystemSurface: Bool
    /// Custom warm surface for themes that do not use system materials.
    let warmSurface: LinearGradient?

    init(
        accent: Color,
        tint: Color,
        stroke: Color,
        shadow: Color,
        usesSystemSurface: Bool,
        warmSurface: LinearGradient? = nil
    ) {
        self.accent = accent
        self.tint = tint
        self.stroke = stroke
        self.shadow = shadow
        self.usesSystemSurface = usesSystemSurface
        self.warmSurface = warmSurface
    }
}
