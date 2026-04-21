import SwiftUI

/// Small, opinionated design tokens for a calm utility widget.
/// Views should prefer these over raw magic numbers.
enum DesignTokens {
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let s: CGFloat = 6
        static let m: CGFloat = 8
        static let l: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let xxxl: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
        static let xl: CGFloat = 18
    }

    enum Size {
        /// Compact default footprint of the main widget panel.
        static let widgetWidth: CGFloat = 260
        static let widgetHeight: CGFloat = 132
        static let panelPadding: CGFloat = 14
        static let progressRingDiameter: CGFloat = 96
        static let progressRingStroke: CGFloat = 4
    }

    enum Elevation {
        static let shadowY: CGFloat = 3
        static let shadowRadius: CGFloat = 14
        static let shadowOpacity: Double = 0.12
    }

    enum Typography {
        /// Large numeral. SF Rounded, monospaced digits.
        static let display = Font.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit()
        /// Section or widget title. Quiet, secondary tone.
        static let title = Font.system(size: 11, weight: .semibold)
        /// Default body text.
        static let body = Font.system(size: 13, weight: .regular)
        /// Supporting caption (subtitles, footers, quiet hints).
        static let caption = Font.system(size: 11, weight: .regular)
        /// Small semibold for inline chips/key caps.
        static let keycap = Font.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit()
    }
}
