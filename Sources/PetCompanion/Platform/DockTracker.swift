import AppKit

struct DockLayout {
    let screen: NSScreen
    let windowFrame: NSRect
    let dockEdge: NSRectEdge
}

final class DockTracker {
    private let activityHeight: CGFloat = 150
    private let bottomInset: CGFloat = 4

    func currentLayout() -> DockLayout? {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return nil
        }

        let frame = screen.frame
        let visible = screen.visibleFrame
        let edge = inferDockEdge(screenFrame: frame, visibleFrame: visible)
        let windowFrame = makeWindowFrame(
            screenFrame: frame,
            visibleFrame: visible,
            dockEdge: edge
        )

        return DockLayout(screen: screen, windowFrame: windowFrame, dockEdge: edge)
    }

    private func inferDockEdge(screenFrame: NSRect, visibleFrame: NSRect) -> NSRectEdge {
        let bottomGap = visibleFrame.minY - screenFrame.minY
        let leftGap = visibleFrame.minX - screenFrame.minX
        let rightGap = screenFrame.maxX - visibleFrame.maxX

        if bottomGap >= leftGap && bottomGap >= rightGap {
            return .minY
        }

        if leftGap >= rightGap {
            return .minX
        }

        return .maxX
    }

    private func makeWindowFrame(
        screenFrame: NSRect,
        visibleFrame: NSRect,
        dockEdge: NSRectEdge
    ) -> NSRect {
        switch dockEdge {
        case .minY:
            return NSRect(
                x: screenFrame.minX,
                y: visibleFrame.minY + bottomInset,
                width: screenFrame.width,
                height: activityHeight
            )
        case .minX:
            return NSRect(
                x: visibleFrame.minX + bottomInset,
                y: screenFrame.minY,
                width: activityHeight,
                height: screenFrame.height
            )
        case .maxX:
            return NSRect(
                x: visibleFrame.maxX - activityHeight - bottomInset,
                y: screenFrame.minY,
                width: activityHeight,
                height: screenFrame.height
            )
        default:
            return NSRect(
                x: screenFrame.minX,
                y: visibleFrame.minY + bottomInset,
                width: screenFrame.width,
                height: activityHeight
            )
        }
    }
}
