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
