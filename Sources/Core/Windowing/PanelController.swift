import AppKit
import SwiftUI

/// Owns the single, always-available floating panel that hosts the counter UI.
///
/// Using an `NSPanel` with `[.borderless, .nonactivatingPanel]` gives us:
///  - a borderless, rounded, system-looking floating surface
///  - clicks that do not steal focus from the frontmost app (non-activating)
///  - correct spaces / full-screen behaviour (join all spaces, stay visible)
///
/// We intentionally do not use `WindowGroup` for the main surface: a utility
/// widget wants less chrome than a document window provides.
@MainActor
final class PanelController {
    private let panel: NSPanel
    private let viewModel: CounterViewModel

    init(viewModel: CounterViewModel) {
        self.viewModel = viewModel

        let contentSize = NSSize(
            width: DesignTokens.Size.widgetWidth,
            height: DesignTokens.Size.widgetHeight
        )

        panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        // Let NSPanel draw the drop shadow so it renders outside the content
        // bounds of the hosting view. SwiftUI shadows would be clipped.
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.minSize = contentSize

        let root = CounterWidgetView(viewModel: viewModel)
        let hosting = NSHostingView(rootView: root)
        hosting.translatesAutoresizingMaskIntoConstraints = false

        // Round the container's backing layer so the NSPanel shadow follows
        // the widget's rounded shape instead of a rectangular bounding box.
        let container = NSView(frame: NSRect(origin: .zero, size: contentSize))
        container.wantsLayer = true
        container.layer?.cornerRadius = DesignTokens.Radius.xl
        container.layer?.masksToBounds = true
        container.layer?.cornerCurve = .continuous

        container.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: container.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        panel.contentView = container
    }

    func show() {
        WindowPositioner.position(panel, for: viewModel.widgetAnchor)
        panel.orderFrontRegardless()
    }

    /// Re-applies the widget corner anchor. Called when the user changes the
    /// anchor in settings; manual drag positions are preserved otherwise.
    func applyAnchor() {
        WindowPositioner.position(panel, for: viewModel.widgetAnchor)
    }
}
