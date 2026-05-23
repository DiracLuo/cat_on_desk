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

    func configure(for dockEdge: NSRectEdge, dockBaseline: CGFloat) {
        self.dockEdge = dockEdge
        movementController.configure(for: dockEdge, dockBaseline: dockBaseline)
        resetPetPositionIfNeeded()
    }

    func setPaused(_ paused: Bool) {
        stateMachine.setPaused(paused, at: lastUpdateTime ?? 0)
        if paused {
            petNode.applyPaused()
        }
    }

    func refreshPreferences() {
        petNode.setDisplayScale(CGFloat(preferences.petScale))
        resetPetPositionIfNeeded()
    }

    func setMouseNearby(_ nearby: Bool, at point: CGPoint? = nil) {
        if nearby, let point {
            petNode.setFacingRight(point.x >= petNode.position.x)
        }
        stateMachine.setWatching(nearby, at: lastUpdateTime ?? 0)
    }

    func handleMouseClick(clickCount: Int) {
        let time = lastUpdateTime ?? 0
        if clickCount >= 2 {
            stateMachine.triggerSleep(at: time)
        } else {
            stateMachine.triggerClickReaction(at: time)
        }
    }

    func isPointNearPet(_ point: CGPoint) -> Bool {
        interactionFrame().contains(point)
    }

    func interactionFrame() -> CGRect {
        CGRect(
            x: petNode.position.x - petNode.petSize.width * 0.62,
            y: petNode.position.y - petNode.petSize.height * 0.62,
            width: petNode.petSize.width * 1.24,
            height: petNode.petSize.height * 1.24
        ).insetBy(dx: -26, dy: -24)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = min(currentTime - (lastUpdateTime ?? currentTime), 1.0 / 15.0)
        lastUpdateTime = currentTime

        stateMachine.update(at: currentTime)

        switch stateMachine.state {
        case .walking:
            updateWalking(deltaTime: deltaTime, currentTime: currentTime)
        case .idle, .looking, .watching:
            let phase = animationController.idlePhase(at: currentTime)
            petNode.applyIdle(phase: phase)
        case .sleeping:
            let phase = animationController.sleepPhase(at: currentTime)
            petNode.applySleeping(phase: phase)
        case .stretching:
            let phase = animationController.stretchPhase(at: currentTime)
            petNode.applyStretching(phase: phase)
        case .meowing:
            let phase = animationController.meowPhase(at: currentTime)
            petNode.applyMeowing(phase: phase)
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

        petNode.position = movementController.dockAlignedPosition(
            currentPosition: petNode.position,
            sceneSize: size,
            petSize: petNode.petSize
        )
    }

    private func resetPetPosition() {
        petNode.position = movementController.startingPosition(in: size, petSize: petNode.petSize)
    }

    func dragPet(to point: CGPoint) {
        petNode.position = movementController.setHomePosition(
            point,
            sceneSize: size,
            petSize: petNode.petSize
        )
        petNode.setFacingRight(point.x >= petNode.position.x)
        stateMachine.setWatching(true, at: lastUpdateTime ?? 0)
    }
}
