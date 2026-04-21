import AppKit
import Carbon.HIToolbox

protocol HotkeyManaging: AnyObject {
    var onHotkeyPressed: (() -> Void)? { get set }
    func startListening(binding: HotkeyBinding)
    func stopListening()
}

/// System-wide hotkey via Carbon `RegisterEventHotKey`.
///
/// Scope:
/// - **Combos** (any modifier-bearing binding) fire globally regardless of
///   which app is frontmost, and require no Accessibility permission. The
///   OS routes the specific registered combo into our app's event loop.
/// - **Plain keys** technically register, but are never a good idea: they
///   would need a CGEventTap (and therefore Accessibility) to actually
///   suppress the key in the frontmost app. We don't take that trust cost
///   for v1. Quiet Mode prevents plain-key bindings by default, and when
///   the user opts out we document the practical consequence clearly.
///
/// This is the same API used by Alfred, Raycast, 1Password, iTerm2, etc.
final class HotkeyService: HotkeyManaging {
    var onHotkeyPressed: (() -> Void)?

    private var binding: HotkeyBinding = AppStateSnapshot.default.hotkey
    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID = EventHotKeyID(signature: OSType(0x4144484B), id: 1) // "ADHK"
    private var eventHandlerRef: EventHandlerRef?

    func startListening(binding: HotkeyBinding) {
        self.binding = binding
        unregisterHotKey()
        ensureInstalledEventHandler()
        registerHotKey()
    }

    func stopListening() {
        unregisterHotKey()
    }

    deinit {
        unregisterHotKey()
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private func ensureInstalledEventHandler() {
        guard eventHandlerRef == nil else { return }

        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, userData in
            guard let userData else { return noErr }
            let service = Unmanaged<HotkeyService>.fromOpaque(userData).takeUnretainedValue()
            var receivedID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &receivedID
            )
            if status == noErr,
               receivedID.signature == service.hotKeyID.signature,
               receivedID.id == service.hotKeyID.id {
                DispatchQueue.main.async {
                    service.onHotkeyPressed?()
                }
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
    }

    private func registerHotKey() {
        guard let keyCode = HotkeyKeyCodes.keyCode(for: binding.key) else { return }
        let modifiers = HotkeyKeyCodes.carbonModifiers(for: binding.modifiers)

        RegisterEventHotKey(
            UInt32(keyCode),
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    private func unregisterHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
}

/// Mapping helpers for Carbon key codes and modifier masks. Kept separate so
/// the Carbon details don't bleed into other layers.
enum HotkeyKeyCodes {
    static func keyCode(for key: String) -> UInt16? {
        if key == " " { return 49 }
        if key == "\r" { return 36 }
        if key == "\t" { return 48 }

        guard key.count == 1 else { return nil }
        switch key {
        case "=", "+":
            // `+` is shift-`=` on a US layout. We register the same physical
            // key; the shift modifier (if any) is conveyed via the modifier mask.
            return 24
        case "-", "_":
            return 27
        case "[", "{": return 33
        case "]", "}": return 30
        case ";", ":": return 41
        case "'", "\"": return 39
        case ",", "<": return 43
        case ".", ">": return 47
        case "/", "?": return 44
        case "\\", "|": return 42
        case "`", "~": return 50
        case "A": return 0
        case "B": return 11
        case "C": return 8
        case "D": return 2
        case "E": return 14
        case "F": return 3
        case "G": return 5
        case "H": return 4
        case "I": return 34
        case "J": return 38
        case "K": return 40
        case "L": return 37
        case "M": return 46
        case "N": return 45
        case "O": return 31
        case "P": return 35
        case "Q": return 12
        case "R": return 15
        case "S": return 1
        case "T": return 17
        case "U": return 32
        case "V": return 9
        case "W": return 13
        case "X": return 7
        case "Y": return 16
        case "Z": return 6
        case "0": return 29
        case "1": return 18
        case "2": return 19
        case "3": return 20
        case "4": return 21
        case "5": return 23
        case "6": return 22
        case "7": return 26
        case "8": return 28
        case "9": return 25
        default:
            return nil
        }
    }

    static func carbonModifiers(for mods: HotkeyModifiers) -> UInt32 {
        var raw: Int = 0
        if mods.contains(.command) { raw |= cmdKey }
        if mods.contains(.option)  { raw |= optionKey }
        if mods.contains(.control) { raw |= controlKey }
        if mods.contains(.shift)   { raw |= shiftKey }
        return UInt32(raw)
    }
}
