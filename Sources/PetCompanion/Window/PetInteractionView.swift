import AppKit
import SpriteKit

final class PetInteractionView: SKView {
    var onMouseDown: ((Int) -> Void)?
    private var singleClickTimer: Timer?

    deinit {
        singleClickTimer?.invalidate()
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount >= 2 {
            singleClickTimer?.invalidate()
            singleClickTimer = nil
            onMouseDown?(event.clickCount)
            return
        }

        singleClickTimer?.invalidate()
        singleClickTimer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: false) { [weak self] _ in
            self?.singleClickTimer = nil
            self?.onMouseDown?(1)
        }
    }
}
