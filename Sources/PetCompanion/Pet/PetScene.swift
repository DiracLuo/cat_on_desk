import AppKit
import SpriteKit

final class PetScene: SKScene {
    private let preferences: AppPreferences
    private let petNode = PetNode()
    private let movementController = PetMovementController()
    private let animationController = PetAnimationController()
    private let stateMachine = PetStateMachine()
    private var lastUpdateTime: TimeInterval?
    private var dockEdge: NSRectEdge = .minY

    init(size: CGSize, preferences: AppPreferences) {
        self.preferences = preferences
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(petNode)
        petNode.setDisplayScale(CGFloat(preferences.petScale))
        resetPetPosition()
    }

    func configure(for dockEdge: NSRectEdge) {
        self.dockEdge = dockEdge
        movementController.configure(for: dockEdge)
        resetPetPositionIfNeeded()
    }

    func setPaused(_ paused: Bool) {
        stateMachine.setPaused(paused, at: lastUpdateTime ?? 0)
        if paused {
            petNode.applyPaused()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = min(currentTime - (lastUpdateTime ?? currentTime), 1.0 / 15.0)
        lastUpdateTime = currentTime

        stateMachine.update(at: currentTime)

        switch stateMachine.state {
        case .walking:
            updateWalking(deltaTime: deltaTime, currentTime: currentTime)
        case .idle:
            let phase = animationController.idlePhase(at: currentTime)
            petNode.applyIdle(phase: phase)
        case .paused:
            petNode.applyPaused()
        }
    }

    private func updateWalking(deltaTime: TimeInterval, currentTime: TimeInterval) {
        let nextPosition = movementController.update(
            position: petNode.position,
            sceneSize: size,
            petSize: petNode.petSize,
            speed: CGFloat(preferences.petSpeed),
            deltaTime: deltaTime
        )
        petNode.position = nextPosition
        petNode.setFacingRight(movementController.direction > 0)
        petNode.applyWalking(phase: animationController.walkingPhase(at: currentTime))
    }

    private func resetPetPositionIfNeeded() {
        guard petNode.parent != nil else {
            return
        }

        let clampedX = min(max(petNode.position.x, petNode.petSize.width * 0.55), size.width - petNode.petSize.width * 0.55)
        let clampedY = min(max(petNode.position.y, petNode.petSize.height * 0.55), size.height - petNode.petSize.height * 0.55)

        if dockEdge == .minY {
            petNode.position = CGPoint(x: clampedX, y: 42)
        } else {
            petNode.position = CGPoint(x: petNode.position.x, y: clampedY)
        }
    }

    private func resetPetPosition() {
        petNode.position = movementController.startingPosition(in: size, petSize: petNode.petSize)
    }
}
