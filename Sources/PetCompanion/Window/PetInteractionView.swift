import AppKit
import SpriteKit

final class PetInteractionView: SKView {
    var onMouseDown: ((Int) -> Void)?
    var onMouseDragged: ((CGPoint) -> Void)?
    private var singleClickTimer: Timer?
    private var mouseDownLocation: CGPoint?
    private var didDrag = false

    deinit {
        singleClickTimer?.invalidate()
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownLocation = event.locationInWindow
        didDrag = false

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

    override func mouseDragged(with event: NSEvent) {
        let location = event.locationInWindow
        if let mouseDownLocation {
            let dx = location.x - mouseDownLocation.x
            let dy = location.y - mouseDownLocation.y
            if hypot(dx, dy) > 4 {
                didDrag = true
                singleClickTimer?.invalidate()
                singleClickTimer = nil
            }
        }

        if didDrag {
            onMouseDragged?(location)
        }
    }

    override func mouseUp(with event: NSEvent) {
        mouseDownLocation = nil
        didDrag = false
    }
}
