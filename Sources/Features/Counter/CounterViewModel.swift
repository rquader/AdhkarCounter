import Foundation
import Observation

@Observable
final class CounterViewModel {
    private let persistence: Persisting
    private let hotkeyService: HotkeyManaging

    private(set) var currentCount: Int

    var targetPreset: TargetPreset
    var customTarget: String
    var displayMode: DisplayMode
    var hotkey: HotkeyBinding
    var requiresModifier: Bool
    var widgetAnchor: WidgetAnchor
    var appTheme: AppTheme
    var showProgressRing: Bool

    var isResetConfirmationShown: Bool
    /// Drives the increment "pulse" micro-interaction.
    private(set) var pulseToken: Int

    init(persistence: Persisting, hotkeyService: HotkeyManaging) {
        self.persistence = persistence
        self.hotkeyService = hotkeyService

        let snapshot = persistence.load()
        self.currentCount = snapshot.currentCount
        self.targetPreset = snapshot.targetPreset
        self.customTarget = snapshot.customTarget.map(String.init) ?? ""
        self.displayMode = snapshot.displayMode
        self.hotkey = snapshot.hotkey
        self.requiresModifier = snapshot.requiresModifier
        self.widgetAnchor = snapshot.widgetAnchor
        self.appTheme = snapshot.theme
        self.showProgressRing = snapshot.showProgressRing
        self.isResetConfirmationShown = false
        self.pulseToken = 0
    }

    // MARK: - Derived

    var targetCount: Int? {
        if targetPreset == .custom {
            return Int(customTarget)
        }
        return targetPreset.defaultValue
    }

    var remainingCount: Int {
        guard let target = targetCount else { return 0 }
        return max(target - currentCount, 0)
    }

    var displayedCount: Int {
        switch displayMode {
        case .completed: return currentCount
        case .remaining: return remainingCount
        }
    }

    var hasReachedTarget: Bool {
        guard let target = targetCount else { return false }
        return currentCount >= target && target > 0
    }

    var progress: Double {
        guard let target = targetCount, target > 0 else { return 0 }
        return min(Double(currentCount) / Double(target), 1.0)
    }

    /// Subtitle line shown beneath the numeral. Switches between target progress
    /// and a quiet hotkey hint.
    var subtitle: String {
        if let target = targetCount {
            switch displayMode {
            case .completed: return "\(currentCount) of \(target)"
            case .remaining: return "\(remainingCount) remaining"
            }
        }
        return "Press \(hotkey.shortDescription) or click to count"
    }

    // MARK: - Lifecycle

    func onAppear() {
        hotkeyService.onHotkeyPressed = { [weak self] in
            Task { @MainActor in
                self?.increment()
            }
        }
        hotkeyService.startListening(binding: hotkey)
    }

    // MARK: - Mutations

    func increment() {
        currentCount += 1
        pulseToken &+= 1
        persist()
    }

    func requestReset() {
        isResetConfirmationShown = true
    }

    func resetConfirmed() {
        currentCount = 0
        isResetConfirmationShown = false
        persist()
    }

    func setHotkey(_ binding: HotkeyBinding) {
        hotkey = enforcePolicy(on: binding)
        applySettings()
    }

    func setRequiresModifier(_ enabled: Bool) {
        requiresModifier = enabled
        if enabled {
            hotkey = enforcePolicy(on: hotkey)
        }
        applySettings()
    }

    func applySettings() {
        if targetPreset != .custom {
            customTarget = ""
        }
        hotkeyService.startListening(binding: hotkey)
        persist()
    }

    // MARK: - Internals

    /// Enforces the "require modifier" policy on a binding. When the toggle
    /// is on, plain keys are promoted to `⌃⌥ + key` so the shortcut never
    /// collides with regular typing.
    private func enforcePolicy(on binding: HotkeyBinding) -> HotkeyBinding {
        guard requiresModifier, binding.modifiers.isEmpty else { return binding }
        return HotkeyBinding(key: binding.key, modifiers: [.control, .option])
    }

    private func persist() {
        persistence.save(
            AppStateSnapshot(
                currentCount: currentCount,
                targetPreset: targetPreset,
                customTarget: Int(customTarget),
                displayMode: displayMode,
                hotkey: hotkey,
                requiresModifier: requiresModifier,
                widgetAnchor: widgetAnchor,
                theme: appTheme,
                showProgressRing: showProgressRing
            )
        )
    }
}

extension HotkeyBinding {
    /// Compact, human-readable form like `⌃⌥+` or `Space`.
    var shortDescription: String {
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option)  { parts.append("⌥") }
        if modifiers.contains(.shift)   { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }

        let label: String
        switch key {
        case " ":  label = "Space"
        case "\r": label = "Return"
        case "\t": label = "Tab"
        default:   label = key
        }

        return parts.joined() + label
    }
}
