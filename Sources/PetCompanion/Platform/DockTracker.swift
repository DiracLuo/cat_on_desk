import AppKit

struct DockLayout {
    let screen: NSScreen
    let windowFrame: NSRect
    let dockEdge: NSRectEdge
    let dockBaseline: CGFloat
}

final class DockTracker {
    private let dockOffset: CGFloat = 13
    private let minimumDockGap: CGFloat = 24

    func currentLayout() -> DockLayout? {
        guard let candidate = bestDockCandidate() else {
            return nil
        }

        let windowFrame = makeWindowFrame(
            screenFrame: candidate.screen.frame,
            visibleFrame: candidate.screen.visibleFrame,
            dockEdge: candidate.edge
        )
        let dockBaseline = makeDockBaseline(
            screenFrame: candidate.screen.frame,
            visibleFrame: candidate.screen.visibleFrame,
            dockEdge: candidate.edge
        )

        return DockLayout(
            screen: candidate.screen,
            windowFrame: windowFrame,
            dockEdge: candidate.edge,
            dockBaseline: dockBaseline
        )
    }

    private func bestDockCandidate() -> (screen: NSScreen, edge: NSRectEdge, gap: CGFloat)? {
        let candidates = NSScreen.screens.map { screen in
            let edge = inferDockEdge(screenFrame: screen.frame, visibleFrame: screen.visibleFrame)
            let gap = dockGap(screenFrame: screen.frame, visibleFrame: screen.visibleFrame, edge: edge)
            return (screen: screen, edge: edge, gap: gap)
        }

        if let dockScreen = candidates
            .filter({ $0.gap >= minimumDockGap })
            .max(by: { $0.gap < $1.gap }) {
            return dockScreen
        }

        guard let fallback = NSScreen.main ?? NSScreen.screens.first else {
            return nil
        }

        let edge = inferDockEdge(screenFrame: fallback.frame, visibleFrame: fallback.visibleFrame)
        let gap = dockGap(screenFrame: fallback.frame, visibleFrame: fallback.visibleFrame, edge: edge)
        return (screen: fallback, edge: edge, gap: gap)
    }

    private func inferDockEdge(screenFrame: NSRect, visibleFrame: NSRect) -> NSRectEdge {
        let bottomGap = dockGap(screenFrame: screenFrame, visibleFrame: visibleFrame, edge: .minY)
        let leftGap = dockGap(screenFrame: screenFrame, visibleFrame: visibleFrame, edge: .minX)
        let rightGap = dockGap(screenFrame: screenFrame, visibleFrame: visibleFrame, edge: .maxX)

        if bottomGap >= leftGap && bottomGap >= rightGap {
            return .minY
        }

        if leftGap >= rightGap {
            return .minX
        }

        return .maxX
    }

    private func dockGap(screenFrame: NSRect, visibleFrame: NSRect, edge: NSRectEdge) -> CGFloat {
        switch edge {
        case .minY:
            return max(0, visibleFrame.minY - screenFrame.minY)
        case .minX:
            return max(0, visibleFrame.minX - screenFrame.minX)
        case .maxX:
            return max(0, screenFrame.maxX - visibleFrame.maxX)
        default:
            return 0
        }
    }

    private func makeWindowFrame(
        screenFrame: NSRect,
        visibleFrame: NSRect,
        dockEdge: NSRectEdge
    ) -> NSRect {
        switch dockEdge {
        case .minY:
            return screenFrame
        case .minX:
            return screenFrame
        case .maxX:
            return screenFrame
        default:
            return screenFrame
        }
    }

    private func makeDockBaseline(
        screenFrame: NSRect,
        visibleFrame: NSRect,
        dockEdge: NSRectEdge
    ) -> CGFloat {
        switch dockEdge {
        case .minY:
            return visibleFrame.minY - screenFrame.minY + dockOffset
        case .minX:
            return visibleFrame.minX - screenFrame.minX + dockOffset
        case .maxX:
            return visibleFrame.maxX - screenFrame.minX - dockOffset
        default:
            return visibleFrame.minY - screenFrame.minY + dockOffset
        }
    }
}
