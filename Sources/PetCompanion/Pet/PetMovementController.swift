import AppKit
import SpriteKit

final class PetMovementController {
    private(set) var direction: CGFloat = 1
    private var dockEdge: NSRectEdge = .minY
    private var dockBaseline: CGFloat = 13
    private var homePosition: CGPoint?

    func configure(for dockEdge: NSRectEdge, dockBaseline: CGFloat) {
        self.dockEdge = dockEdge
        self.dockBaseline = dockBaseline
    }

    func startingPosition(in size: CGSize, petSize: CGSize) -> CGPoint {
        let position: CGPoint
        switch dockEdge {
        case .minY:
            position = CGPoint(x: max(petSize.width, size.width * 0.5), y: dockBaseline)
        case .minX:
            position = CGPoint(x: dockBaseline, y: max(petSize.height, size.height * 0.5))
        case .maxX:
            position = CGPoint(x: dockBaseline, y: max(petSize.height, size.height * 0.5))
        default:
            position = CGPoint(x: max(petSize.width, size.width * 0.5), y: dockBaseline)
        }
        homePosition = position
        return position
    }

    func dockAlignedPosition(currentPosition: CGPoint, sceneSize: CGSize, petSize: CGSize) -> CGPoint {
        var next = currentPosition

        switch dockEdge {
        case .minY:
            let minX = petSize.width * 0.55
            let maxX = max(minX, sceneSize.width - petSize.width * 0.55)
            next.x = min(max(next.x, minX), maxX)
            next.y = dockBaseline
        case .minX:
            let minY = petSize.height * 0.55
            let maxY = max(minY, sceneSize.height - petSize.height * 0.55)
            next.x = dockBaseline
            next.y = min(max(next.y, minY), maxY)
        case .maxX:
            let minY = petSize.height * 0.55
            let maxY = max(minY, sceneSize.height - petSize.height * 0.55)
            next.x = dockBaseline
            next.y = min(max(next.y, minY), maxY)
        default:
            break
        }

        homePosition = clampedHome(from: homePosition ?? next, sceneSize: sceneSize, petSize: petSize)
        return next
    }

    func setHomePosition(_ position: CGPoint, sceneSize: CGSize, petSize: CGSize) -> CGPoint {
        let clamped = clampedFreePosition(position, sceneSize: sceneSize, petSize: petSize)
        homePosition = clamped
        return clamped
    }

    func update(position: CGPoint, sceneSize: CGSize, petSize: CGSize, speed: CGFloat, deltaTime: TimeInterval) -> CGPoint {
        var next = position
        let distance = speed * CGFloat(deltaTime)

        switch dockEdge {
        case .minY:
            next.x += direction * distance
            let bounds = walkingBounds(sceneSize: sceneSize, petSize: petSize)
            let minX = bounds.lowerBound
            let maxX = bounds.upperBound
            if next.x <= minX {
                next.x = minX
                direction = 1
            } else if next.x >= maxX {
                next.x = maxX
                direction = -1
            }
        case .minX, .maxX:
            next.y += direction * distance
            let bounds = walkingBounds(sceneSize: sceneSize, petSize: petSize)
            let minY = bounds.lowerBound
            let maxY = bounds.upperBound
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

    private func walkingBounds(sceneSize: CGSize, petSize: CGSize) -> ClosedRange<CGFloat> {
        switch dockEdge {
        case .minY:
            let fullMin = petSize.width * 0.55
            let fullMax = max(fullMin, sceneSize.width - petSize.width * 0.55)
            let center = clampedHome(from: homePosition ?? CGPoint(x: sceneSize.width * 0.5, y: dockBaseline), sceneSize: sceneSize, petSize: petSize).x
            let halfRange = sceneSize.width / 6
            return max(fullMin, center - halfRange)...min(fullMax, center + halfRange)
        case .minX, .maxX:
            let fullMin = petSize.height * 0.55
            let fullMax = max(fullMin, sceneSize.height - petSize.height * 0.55)
            let center = clampedHome(from: homePosition ?? CGPoint(x: dockBaseline, y: sceneSize.height * 0.5), sceneSize: sceneSize, petSize: petSize).y
            let halfRange = sceneSize.height / 6
            return max(fullMin, center - halfRange)...min(fullMax, center + halfRange)
        default:
            return 0...0
        }
    }

    private func clampedHome(from position: CGPoint, sceneSize: CGSize, petSize: CGSize) -> CGPoint {
        var next = position

        switch dockEdge {
        case .minY:
            let minX = petSize.width * 0.55
            let maxX = max(minX, sceneSize.width - petSize.width * 0.55)
            next.x = min(max(next.x, minX), maxX)
            next.y = dockBaseline
        case .minX:
            let minY = petSize.height * 0.55
            let maxY = max(minY, sceneSize.height - petSize.height * 0.55)
            next.x = dockBaseline
            next.y = min(max(next.y, minY), maxY)
        case .maxX:
            let minY = petSize.height * 0.55
            let maxY = max(minY, sceneSize.height - petSize.height * 0.55)
            next.x = dockBaseline
            next.y = min(max(next.y, minY), maxY)
        default:
            break
        }

        return next
    }

    private func clampedFreePosition(_ position: CGPoint, sceneSize: CGSize, petSize: CGSize) -> CGPoint {
        let minX = petSize.width * 0.55
        let maxX = max(minX, sceneSize.width - petSize.width * 0.55)
        let minY = petSize.height * 0.55
        let maxY = max(minY, sceneSize.height - petSize.height * 0.55)

        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }
}
