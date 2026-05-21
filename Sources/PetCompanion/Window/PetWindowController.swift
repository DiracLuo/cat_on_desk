import AppKit
import SpriteKit

final class PetWindowController {
    private let dockTracker: DockTracker
    private let preferences: AppPreferences
    private var window: PetOverlayWindow?
    private var scene: PetScene?

    init(dockTracker: DockTracker, preferences: AppPreferences) {
        self.dockTracker = dockTracker
        self.preferences = preferences
    }

    func show() {
        guard let layout = dockTracker.currentLayout() else {
            return
        }

        let overlayWindow = PetOverlayWindow(frame: layout.windowFrame)
        let skView = SKView(frame: NSRect(origin: .zero, size: layout.windowFrame.size))
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
        petScene.configure(for: layout.dockEdge)

        skView.presentScene(petScene)
        overlayWindow.contentView = skView
        overlayWindow.orderFrontRegardless()

        window = overlayWindow
        scene = petScene
    }

    func close() {
        window?.close()
        window = nil
        scene = nil
    }

    func reposition() {
        guard let layout = dockTracker.currentLayout() else {
            return
        }

        if window == nil {
            show()
            return
        }

        window?.setFrame(layout.windowFrame, display: true)
        if let skView = window?.contentView as? SKView {
            skView.frame = NSRect(origin: .zero, size: layout.windowFrame.size)
        }
        scene?.size = layout.windowFrame.size
        scene?.configure(for: layout.dockEdge)
    }

    func setPaused(_ isPaused: Bool) {
        scene?.setPaused(isPaused)
    }
}
