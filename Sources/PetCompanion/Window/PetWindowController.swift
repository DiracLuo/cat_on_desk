import AppKit
import SpriteKit

final class PetWindowController {
    private let dockTracker: DockTracker
    private let preferences: AppPreferences
    private var window: PetOverlayWindow?
    private var scene: PetScene?
    private var currentLayout: DockLayout?
    private var interactionTimer: Timer?
    private var isCapturingMouse = false

    init(dockTracker: DockTracker, preferences: AppPreferences) {
        self.dockTracker = dockTracker
        self.preferences = preferences
    }

    func show() {
        guard let layout = dockTracker.currentLayout() else {
            return
        }

        let overlayWindow = PetOverlayWindow(frame: layout.windowFrame)
        let skView = PetInteractionView(frame: NSRect(origin: .zero, size: layout.windowFrame.size))
        skView.allowsTransparency = true
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 30
        skView.wantsLayer = true
        skView.layer?.isOpaque = false
        skView.layer?.backgroundColor = NSColor.clear.cgColor

        let petScene = PetScene(size: layout.windowFrame.size, preferences: preferences)
        petScene.scaleMode = .resizeFill
        petScene.backgroundColor = .clear
        petScene.anchorPoint = CGPoint(x: 0, y: 0)
        petScene.configure(for: layout.dockEdge, dockBaseline: layout.dockBaseline)

        skView.presentScene(petScene)
        skView.onMouseDown = { [weak petScene] clickCount in
            petScene?.handleMouseClick(clickCount: clickCount)
        }
        skView.onMouseDragged = { [weak petScene] point in
            petScene?.dragPet(to: point)
        }
        overlayWindow.contentView = skView
        applyWindowBehavior(to: overlayWindow)
        overlayWindow.orderFrontRegardless()

        window = overlayWindow
        scene = petScene
        currentLayout = layout
        startInteractionTracking()
    }

    func close() {
        stopInteractionTracking()
        window?.close()
        window = nil
        scene = nil
    }

    func reposition(force: Bool = false) {
        guard let layout = dockTracker.currentLayout() else {
            return
        }

        if window == nil {
            show()
            return
        }

        guard force || shouldApply(layout) else {
            return
        }

        window?.setFrame(layout.windowFrame, display: true)
        if let skView = window?.contentView as? SKView {
            skView.frame = NSRect(origin: .zero, size: layout.windowFrame.size)
        }
        scene?.size = layout.windowFrame.size
        scene?.configure(for: layout.dockEdge, dockBaseline: layout.dockBaseline)
        if let window {
            applyWindowBehavior(to: window)
        }
        currentLayout = layout
    }

    func repositionIfNeeded() {
        reposition(force: false)
    }

    func setPaused(_ isPaused: Bool) {
        scene?.setPaused(isPaused)
    }

    func preferencesDidChange() {
        scene?.refreshPreferences()
        if let window {
            applyWindowBehavior(to: window)
        }
    }

    private func applyWindowBehavior(to window: PetOverlayWindow) {
        var behavior: NSWindow.CollectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        if preferences.showInFullScreen {
            behavior.insert(.fullScreenAuxiliary)
        }
        window.collectionBehavior = behavior
    }

    private func startInteractionTracking() {
        interactionTimer?.invalidate()
        interactionTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            self?.updateMouseInteraction()
        }
        interactionTimer?.tolerance = 0.04
    }

    private func stopInteractionTracking() {
        interactionTimer?.invalidate()
        interactionTimer = nil
    }

    private func updateMouseInteraction() {
        guard let window, let scene else {
            return
        }

        let screenPoint = NSEvent.mouseLocation
        let windowPoint = window.convertPoint(fromScreen: screenPoint)
        let scenePoint = CGPoint(x: windowPoint.x, y: windowPoint.y)
        let isNearby = scene.isPointNearPet(scenePoint)

        if isNearby != isCapturingMouse {
            isCapturingMouse = isNearby
            window.ignoresMouseEvents = !isNearby
        }
        scene.setMouseNearby(isNearby, at: scenePoint)
    }

    private func shouldApply(_ layout: DockLayout) -> Bool {
        guard let currentLayout else {
            return true
        }

        return currentLayout.dockEdge != layout.dockEdge
            || !currentLayout.screen.frame.isApproximatelyEqual(to: layout.screen.frame)
            || !currentLayout.windowFrame.isApproximatelyEqual(to: layout.windowFrame)
            || abs(currentLayout.dockBaseline - layout.dockBaseline) > 1
    }
}

private extension NSRect {
    func isApproximatelyEqual(to other: NSRect, tolerance: CGFloat = 1) -> Bool {
        abs(origin.x - other.origin.x) <= tolerance
            && abs(origin.y - other.origin.y) <= tolerance
            && abs(size.width - other.size.width) <= tolerance
            && abs(size.height - other.size.height) <= tolerance
    }
}
