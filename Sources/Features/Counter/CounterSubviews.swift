import SwiftUI

// MARK: - Header

struct WidgetHeaderView: View {
    @Bindable var viewModel: CounterViewModel
    @State private var isHoveringGear: Bool = false

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Button(action: openSettings) {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.small)
                    .foregroundStyle(isHoveringGear ? .secondary : .tertiary)
                    .padding(DesignTokens.Spacing.xs)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHoveringGear = $0 }
            .accessibilityLabel("Open Settings")
            .help("Settings (⌘,)")

            Spacer(minLength: 0)

            Text("Adhkar")
                .font(DesignTokens.Typography.title)
                .foregroundStyle(.secondary)
                .tracking(0.4)

            Spacer(minLength: 0)

            // Symmetry slot keeps the title visually centered.
            Color.clear
                .frame(width: 18, height: 18)
        }
        .frame(height: 18)
    }

    private func openSettings() {
        // Activate the app so the Settings scene can be fronted, then request
        // SwiftUI to show it. The selector is spelled as a dynamic string to
        // avoid referencing an API symbol not available at compile time.
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

// MARK: - Numeral + progress ring

struct CounterNumeralView: View {
    let displayed: Int
    let isComplete: Bool
    let progress: Double
    let palette: ThemePalette
    let pulse: Bool
    let onIncrement: () -> Void

    var body: some View {
        Button(action: onIncrement) {
            ZStack {
                if progress > 0 {
                    ProgressRingView(progress: progress, palette: palette, isComplete: isComplete)
                        .frame(
                            width: DesignTokens.Size.progressRingDiameter,
                            height: DesignTokens.Size.progressRingDiameter
                        )
                }

                Text("\(displayed)")
                    .font(DesignTokens.Typography.display)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(isComplete ? palette.accent : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .scaleEffect(pulse ? 1.04 : 1.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Increment counter")
        .accessibilityValue("\(displayed)")
    }
}

struct ProgressRingView: View {
    let progress: Double
    let palette: ThemePalette
    let isComplete: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(palette.accent.opacity(0.12), lineWidth: DesignTokens.Size.progressRingStroke)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    palette.accent.opacity(isComplete ? 1.0 : 0.85),
                    style: StrokeStyle(
                        lineWidth: DesignTokens.Size.progressRingStroke,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.25), value: progress)
        }
    }
}

// MARK: - Subtitle

struct WidgetSubtitleView: View {
    let text: String
    let isComplete: Bool
    let palette: ThemePalette
    let onReset: () -> Void

    @State private var isHoveringReset: Bool = false

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.s) {
            Text(text)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(isComplete ? palette.accent : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            Button(action: onReset) {
                Text("Reset")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(isHoveringReset ? .secondary : .tertiary)
            }
            .buttonStyle(.plain)
            .onHover { isHoveringReset = $0 }
            .help("Reset counter to zero")
            .accessibilityLabel("Reset counter")
        }
        .frame(height: 16)
    }
}
