import SwiftUI

/// The calm, always-on-top dhikr counter surface.
///
/// Layout priorities:
///  1. The numeral is the focal point; everything else is quiet.
///  2. The entire centre region is an increment target — effortless counting.
///  3. Controls (settings, reset) are de-emphasised to the header corners.
struct CounterWidgetView: View {
    @Bindable var viewModel: CounterViewModel
    @State private var pulse: Bool = false

    private var palette: ThemePalette { viewModel.appTheme.palette }

    var body: some View {
        ZStack {
            WidgetSurface(palette: palette)

            VStack(spacing: DesignTokens.Spacing.xs) {
                WidgetHeaderView(viewModel: viewModel)

                CounterNumeralView(
                    displayed: viewModel.displayedCount,
                    isComplete: viewModel.hasReachedTarget,
                    showRing: viewModel.showProgressRing && viewModel.targetCount != nil,
                    progress: viewModel.progress,
                    palette: palette,
                    pulse: pulse,
                    onIncrement: handleIncrement
                )
                .frame(maxHeight: .infinity)

                WidgetSubtitleView(
                    text: viewModel.subtitle,
                    isComplete: viewModel.hasReachedTarget,
                    palette: palette,
                    onReset: viewModel.resetConfirmed
                )
            }
            .padding(DesignTokens.Size.panelPadding)
        }
        .frame(
            minWidth: DesignTokens.Size.widgetWidth,
            minHeight: DesignTokens.Size.widgetHeight
        )
        .onChange(of: viewModel.pulseToken) { _, _ in
            triggerPulse()
        }
    }

    private func handleIncrement() {
        viewModel.increment()
    }

    private func triggerPulse() {
        withAnimation(.spring(response: 0.18, dampingFraction: 0.55)) {
            pulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
                pulse = false
            }
        }
    }
}

/// Rounded surface with theme-aware fill and a hairline stroke.
///
/// Elevation (the window drop shadow) is drawn by the hosting `NSPanel`, not
/// by SwiftUI — a SwiftUI `.shadow` inside an `NSHostingView` would be clipped
/// by the host's bounds. See `PanelController.hasShadow`.
private struct WidgetSurface: View {
    let palette: ThemePalette

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous)
        ZStack {
            if palette.usesSystemSurface {
                shape.fill(.regularMaterial)
                shape.fill(palette.tint)
            } else if let surface = palette.warmSurface {
                shape.fill(surface)
            } else {
                shape.fill(.regularMaterial)
            }
            shape.strokeBorder(palette.stroke, lineWidth: 0.7)
        }
    }
}
