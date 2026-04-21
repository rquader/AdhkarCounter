import AppKit

enum WindowPositioner {
    static func position(_ window: NSWindow, for anchor: WidgetAnchor, padding: CGFloat = 18) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let size = window.frame.size

        let origin: CGPoint
        switch anchor {
        case .topLeft:
            origin = CGPoint(
                x: screenFrame.minX + padding,
                y: screenFrame.maxY - size.height - padding
            )
        case .topRight:
            origin = CGPoint(
                x: screenFrame.maxX - size.width - padding,
                y: screenFrame.maxY - size.height - padding
            )
        case .bottomLeft:
            origin = CGPoint(
                x: screenFrame.minX + padding,
                y: screenFrame.minY + padding
            )
        case .bottomRight:
            origin = CGPoint(
                x: screenFrame.maxX - size.width - padding,
                y: screenFrame.minY + padding
            )
        }

        window.setFrameOrigin(origin)
    }
}
