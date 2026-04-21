# AdhkarCounter

A calm, privacy-first floating dhikr counter for macOS.

A tiny, always-available number in the corner of your screen. Press a keyboard shortcut from any app and it goes up. That's the app.

- Works globally from any app — default shortcut `⌃⌥=`
- No network, no analytics, no accounts, no cloud sync
- Native `NSPanel` widget, not a window with traffic-lights
- Four calm themes, optional progress ring toward a target
- Local persistence only (`UserDefaults`)

## Requirements

- macOS 14 (Sonoma) or later
- Swift 5.10+ toolchain (ships with Xcode 15.3+)

## Build and run

```bash
swift build
.build/debug/AdhkarCounter
```

For a release build:

```bash
swift build -c release
.build/release/AdhkarCounter
```

The app runs as an accessory — no Dock icon, no app-switcher entry. Settings open with `⌘,` or the gear icon on the widget.

## Using the hotkey

The default shortcut is `⌃⌥=`. Press it from any app and the counter increments. No permission prompt, no accessibility hooks — this uses Carbon `RegisterEventHotKey`, which registers one specific combo system-wide.

You can change the shortcut in Settings. If you turn off "Require modifier key" you can bind a plain key like `=`, but note the tradeoff: the key will still be typed into whatever app you are in. A small info popover next to the toggle explains this in more detail.

## Project structure

```
Sources/
  App/                 # @main, NSApplicationDelegate, Settings scene
  Core/
    DesignSystem/      # tokens, themes, semantic colour roles
    Model/             # AppStateSnapshot and supporting types
    Services/          # Carbon hotkey, persistence, launch-at-login stub
    Windowing/         # NSPanel controller and corner snap
  Features/
    Counter/           # widget view, numeral, progress ring, view-model
    Settings/          # Settings Form and key-capture field
```

## Design decisions

Load-bearing decisions live in Architecture Decision Records. They're kept in a separate Obsidian vault rather than in this repo so the design conversations stay with the author's notes. If you want the full reasoning, the key headlines are:

- **Why an NSPanel, not a SwiftUI WindowGroup.** A utility widget wants less chrome than a document window provides, and a non-activating panel won't steal focus from the app you're working in.
- **Why Carbon for the hotkey.** `RegisterEventHotKey` registers a single specific combo system-wide with no permission prompt. Same mechanism used by Alfred, Raycast, 1Password, iTerm2 and Electron's `globalShortcut`.
- **Why plain-key global suppression is not in v1.** Suppressing a plain key from the frontmost app would need a `CGEventTap` and Accessibility permission. Modifier combos already solve the stated user goal, so we don't take that trust cost.
- **Themes are semantic.** Each `AppTheme` maps to a `ThemePalette` of roles (`accent`, `tint`, `stroke`, `shadow`, surface strategy). Views compose with roles, not raw colours.

## Licence

MIT. See `LICENSE`.
