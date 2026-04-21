import AppKit
import SwiftUI

@main
struct AdhkarCounterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            if let viewModel = appDelegate.viewModel {
                SettingsView(viewModel: viewModel)
                    .frame(width: 460, height: 520)
            } else {
                Color.clear.frame(width: 1, height: 1)
            }
        }
    }
}

/// Owns app-lifetime state. The main UI is a borderless `NSPanel` rather than
/// a `WindowGroup`, so we drive setup through an `NSApplicationDelegate`.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) var viewModel: CounterViewModel?
    private var panelController: PanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Utility widget: no Dock icon, no app-switcher entry.
        NSApp.setActivationPolicy(.accessory)

        let viewModel = CounterViewModel(
            persistence: PersistenceService(),
            hotkeyService: HotkeyService()
        )
        self.viewModel = viewModel

        let controller = PanelController(viewModel: viewModel)
        self.panelController = controller

        viewModel.onAppear()
        controller.show()

        // Re-anchor when the user explicitly changes the corner. Theme and
        // other settings do not move the window.
        trackAnchorChanges()
    }

    /// Uses `Observation.withObservationTracking` to observe `widgetAnchor`
    /// without any polling or Combine. The closure re-registers itself on
    /// every change to mimic a continuous observation.
    private func trackAnchorChanges() {
        guard let viewModel else { return }
        withObservationTracking {
            _ = viewModel.widgetAnchor
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.panelController?.applyAnchor()
                self?.trackAnchorChanges()
            }
        }
    }
}
