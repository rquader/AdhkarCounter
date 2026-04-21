import Foundation

enum DisplayMode: String, Codable, CaseIterable {
    case completed
    case remaining
}

enum TargetPreset: String, Codable, CaseIterable, Identifiable {
    case off
    case thirtyThree
    case oneHundred
    case custom

    var id: String { rawValue }

    var defaultValue: Int? {
        switch self {
        case .off:
            return nil
        case .thirtyThree:
            return 33
        case .oneHundred:
            return 100
        case .custom:
            return nil
        }
    }
}

enum WidgetAnchor: String, Codable, CaseIterable, Identifiable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        }
    }
}

/// Modifier mask for a hotkey binding. Mirrors Carbon's modifier bits at the
/// model layer so persisted state stays independent of any AppKit API.
struct HotkeyModifiers: OptionSet, Codable, Equatable, Hashable {
    let rawValue: Int

    init(rawValue: Int) { self.rawValue = rawValue }

    static let command = HotkeyModifiers(rawValue: 1 << 0)
    static let option  = HotkeyModifiers(rawValue: 1 << 1)
    static let control = HotkeyModifiers(rawValue: 1 << 2)
    static let shift   = HotkeyModifiers(rawValue: 1 << 3)
}

struct HotkeyBinding: Codable, Equatable {
    /// A single printable key (upper-cased letters, digits, `=`, `+`) or a
    /// special placeholder like `" "` (space).
    var key: String
    /// Modifier mask. Empty means a plain key — allowed but discouraged (see
    /// `requiresModifier` in `AppStateSnapshot`).
    var modifiers: HotkeyModifiers

    init(key: String, modifiers: HotkeyModifiers = []) {
        self.key = key
        self.modifiers = modifiers
    }

    var isPlainKey: Bool { modifiers.isEmpty }
}

struct AppStateSnapshot: Codable {
    var currentCount: Int
    var targetPreset: TargetPreset
    var customTarget: Int?
    var displayMode: DisplayMode
    var hotkey: HotkeyBinding
    /// When true, the hotkey picker refuses plain keys and auto-promotes them
    /// to `⌃⌥ + key`. Prevents the shortcut from colliding with typing.
    var requiresModifier: Bool
    var widgetAnchor: WidgetAnchor
    var theme: AppTheme
    /// Whether the progress ring is rendered behind the numeral when a target
    /// is set.
    var showProgressRing: Bool
}

extension AppStateSnapshot {
    static let `default` = AppStateSnapshot(
        currentCount: 0,
        targetPreset: .oneHundred,
        customTarget: nil,
        displayMode: .remaining,
        hotkey: HotkeyBinding(key: "=", modifiers: [.control, .option]),
        requiresModifier: true,
        widgetAnchor: .topRight,
        theme: .naturalGreen,
        showProgressRing: true
    )
}

/// Custom decoding so future snapshot shape changes can add fields without
/// losing user data. Every field falls back to a sensible default if absent.
extension AppStateSnapshot {
    enum CodingKeys: String, CodingKey {
        case currentCount, targetPreset, customTarget, displayMode
        case hotkey, requiresModifier, widgetAnchor, theme, showProgressRing
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentCount = try container.decodeIfPresent(Int.self, forKey: .currentCount) ?? 0
        self.targetPreset = try container.decodeIfPresent(TargetPreset.self, forKey: .targetPreset) ?? .oneHundred
        self.customTarget = try container.decodeIfPresent(Int.self, forKey: .customTarget)
        self.displayMode = try container.decodeIfPresent(DisplayMode.self, forKey: .displayMode) ?? .remaining
        self.requiresModifier = try container.decodeIfPresent(Bool.self, forKey: .requiresModifier) ?? true
        self.widgetAnchor = try container.decodeIfPresent(WidgetAnchor.self, forKey: .widgetAnchor) ?? .topRight
        self.theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .naturalGreen
        self.showProgressRing = try container.decodeIfPresent(Bool.self, forKey: .showProgressRing) ?? true
        self.hotkey = try container.decodeIfPresent(HotkeyBinding.self, forKey: .hotkey)
            ?? AppStateSnapshot.default.hotkey
    }
}
