import AppKit
import SwiftUI

/// A capture field that records a key + modifier combination while focused.
///
/// We intentionally capture only while focused (no global key tracking) to
/// honour the privacy posture. The resulting binding is passed back as a
/// `HotkeyBinding` value.
struct KeyCaptureField: NSViewRepresentable {
    @Binding var binding: HotkeyBinding
    /// When true, plain (no-modifier) captures are auto-promoted to `⌃⌥ + key`
    /// before being stored. Matches the "Require modifier key" setting.
    var requiresModifier: Bool

    final class Coordinator {
        var binding: HotkeyBinding
        var requiresModifier: Bool

        init(binding: HotkeyBinding, requiresModifier: Bool) {
            self.binding = binding
            self.requiresModifier = requiresModifier
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: binding, requiresModifier: requiresModifier)
    }

    func makeNSView(context: Context) -> NSView {
        let coordinator = context.coordinator
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let field = KeyCaptureNSView()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholderString = "Click, then press your combo"
        field.displayBinding = coordinator.binding
        field.onCapturedBinding = { captured in
            let accepted: HotkeyBinding
            if coordinator.requiresModifier, captured.modifiers.isEmpty {
                // Promote plain keys to ⌃⌥ + key so the shortcut cannot
                // collide with regular typing.
                accepted = HotkeyBinding(key: captured.key, modifiers: [.control, .option])
            } else {
                accepted = captured
            }
            DispatchQueue.main.async {
                self.binding = accepted
                coordinator.binding = accepted
                field.displayBinding = accepted
            }
        }

        container.addSubview(field)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            field.topAnchor.constraint(equalTo: container.topAnchor),
            field.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            field.heightAnchor.constraint(equalToConstant: 28)
        ])

        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let field = nsView.subviews.first as? KeyCaptureNSView else { return }
        context.coordinator.binding = binding
        context.coordinator.requiresModifier = requiresModifier
        field.displayBinding = binding
        field.needsDisplay = true
    }
}

private final class KeyCaptureNSView: NSView {
    var onCapturedBinding: ((HotkeyBinding) -> Void)?

    var placeholderString: String = "" { didSet { needsDisplay = true } }

    var displayBinding: HotkeyBinding = .init(key: "=") {
        didSet { needsDisplay = true }
    }

    private var isFocused: Bool = false {
        didSet { needsDisplay = true }
    }

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func becomeFirstResponder() -> Bool {
        isFocused = true
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        isFocused = false
        return super.resignFirstResponder()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 6, yRadius: 6)
        let strokeColor: NSColor = isFocused
            ? NSColor.controlAccentColor.withAlphaComponent(0.8)
            : NSColor.separatorColor.withAlphaComponent(0.6)
        strokeColor.setStroke()
        path.lineWidth = isFocused ? 1.2 : 1.0
        path.stroke()

        let display = displayBinding.shortDescription
        let hasValue = !display.isEmpty

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: hasValue ? .semibold : .regular),
            .foregroundColor: hasValue ? NSColor.labelColor : NSColor.secondaryLabelColor
        ]
        let text = hasValue ? display : placeholderString
        let textSize = (text as NSString).size(withAttributes: attrs)
        let rect = NSRect(
            x: bounds.minX + 10,
            y: bounds.midY - textSize.height / 2,
            width: bounds.width - 20,
            height: textSize.height
        )
        (text as NSString).draw(in: rect, withAttributes: attrs)
    }

    override func keyDown(with event: NSEvent) {
        let raw = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var mods: HotkeyModifiers = []
        if raw.contains(.command) { mods.insert(.command) }
        if raw.contains(.option)  { mods.insert(.option) }
        if raw.contains(.control) { mods.insert(.control) }
        if raw.contains(.shift)   { mods.insert(.shift) }

        // Use charactersIgnoringModifiers so `⇧=` resolves to `=`, not `+`.
        let key: String? = {
            if event.keyCode == 49 { return " " }
            if event.keyCode == 36 { return "\r" }
            if event.keyCode == 48 { return "\t" }
            if let chars = event.charactersIgnoringModifiers, let first = chars.first {
                return String(first).uppercased()
            }
            return nil
        }()

        guard let key else {
            super.keyDown(with: event)
            return
        }

        onCapturedBinding?(HotkeyBinding(key: key, modifiers: mods))
        needsDisplay = true
    }
}
