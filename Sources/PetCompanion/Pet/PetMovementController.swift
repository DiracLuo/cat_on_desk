import AppKit
import SpriteKit

final class PetMovementController {
    private(set) var direction: CGFloat = 1
    private var dockEdge: NSRectEdge = .minY

    func configure(for dockEdge: NSRectEdge) {
        self.dockEdge = dockEdge
    }

    func startingPosition(in size: CGSize, petSize: CGSize) -> CGPoint {
        switch dockEdge {
        case .minY:
            return CGPoint(x: max(petSize.width, size.width * 0.2), y: 42)
        case .minX:
            return CGPoint(x: 54, y: max(petSize.height, size.height * 0.2))
        case .maxX:
            return CGPoint(x: size.width - 54, y: max(petSize.height, size.height * 0.2))
        default:
            return CGPoint(x: max(petSize.width, size.width * 0.2), y: 42)
        }
    }

    func update(position: CGPoint, sceneSize: CGSize, petSize: CGSize, speed: CGFloat, deltaTime: TimeInterval) -> CGPoint {
        var next = position
        let distance = speed * CGFloat(deltaTime)

        switch dockEdge {
        case .minY:
            next.x += direction * distance
            let minX = petSize.width * 0.55
            let maxX = max(minX, sceneSize.width - petSize.width * 0.55)
            if next.x <= minX {
                next.x = minX
                direction = 1
            } else if next.x >= maxX {
                next.x = maxX
                direction = -1
            }
        case .minX, .maxX:
            next.y += direction * distance
            let minY = petSize.height * 0.55
            let maxY = max(minY, sceneSize.height - petSize.height * 0.55)
            if next.y <= minY {
                next.y = minY
                direction = 1
            } else if next.y >= maxY {
                next.y = maxY
                direction = -1
            }
        default:
            break
        }

        return next
    }
}
