import AppKit
import SpriteKit

final class PetNode: SKNode {
    private let visualRoot = SKNode()
    private let spriteNode = SKSpriteNode()
    private let meowLabel = SKLabelNode(text: "喵！")
    private var baseScale: CGFloat = 1
    private var facingRight = true
    private var currentAnimation: PetAnimation?
    private var currentFrameIndex = -1

    var petSize: CGSize {
        CGSize(width: 118 * baseScale, height: 94 * baseScale)
    }

    override init() {
        super.init()
        build()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }

    func setDisplayScale(_ scale: CGFloat) {
        baseScale = scale
        applyFacing()
    }

    func setFacingRight(_ isFacingRight: Bool) {
        facingRight = isFacingRight
        applyFacing()
    }

    func applyWalking(phase: Double) {
        apply(animation: .walk, phase: phase)
    }

    func applyIdle(phase: Double) {
        apply(animation: .idle, phase: phase)
    }

    func applySleeping(phase: Double) {
        apply(animation: .sleep, phase: phase)
    }

    func applyStretching(phase: Double) {
        apply(animation: .stretch, phase: phase)
    }

    func applyMeowing(phase: Double) {
        apply(animation: .meow, phase: phase)
    }

    func applyPaused() {
        apply(animation: .idle, phase: 0)
    }

    private func build() {
        removeAllChildren()
        addChild(visualRoot)
        visualRoot.addChild(spriteNode)
        addChild(meowLabel)
        spriteNode.size = CGSize(width: 160, height: 128)
        spriteNode.anchorPoint = CGPoint(x: 0.5, y: 0.1)
        meowLabel.fontName = "PingFangSC-Semibold"
        meowLabel.fontSize = 14
        meowLabel.fontColor = NSColor(calibratedWhite: 0.1, alpha: 1)
        meowLabel.horizontalAlignmentMode = .center
        meowLabel.verticalAlignmentMode = .center
        meowLabel.zPosition = 10
        meowLabel.isHidden = true
        applyFacing()
        applyIdle(phase: 0)
    }

    private func apply(animation: PetAnimation, phase: Double) {
        let frames = CatSpriteLibrary.shared.frames(for: animation)
        if frames.isEmpty {
            applyFallback(animation: animation, phase: phase)
            return
        }

        let index = min(frames.count - 1, Int(phase * Double(frames.count)))
        if currentAnimation != animation || currentFrameIndex != index {
            spriteNode.texture = frames[index]
            currentAnimation = animation
            currentFrameIndex = index
        }
        meowLabel.isHidden = animation != .meow
        spriteNode.colorBlendFactor = 0
    }

    private func applyFallback(animation: PetAnimation, phase: Double) {
        if spriteNode.texture != nil {
            spriteNode.texture = nil
        }

        let color: NSColor
        switch animation {
        case .walk:
            color = NSColor(calibratedRed: 1.0, green: 0.72, blue: 0.42, alpha: 1)
        case .idle:
            color = NSColor(calibratedRed: 1.0, green: 0.78, blue: 0.5, alpha: 1)
        case .sleep:
            color = NSColor(calibratedRed: 0.92, green: 0.66, blue: 0.45, alpha: 1)
        case .stretch:
            color = NSColor(calibratedRed: 1.0, green: 0.64, blue: 0.35, alpha: 1)
        case .meow:
            color = NSColor(calibratedRed: 1.0, green: 0.82, blue: 0.44, alpha: 1)
        }
        spriteNode.color = color
        spriteNode.colorBlendFactor = 1
        spriteNode.size = CGSize(width: 104, height: 72 + CGFloat(sin(phase * .pi * 2)) * 3)
        meowLabel.isHidden = animation != .meow
    }

    private func applyFacing() {
        visualRoot.xScale = (facingRight ? 1 : -1) * baseScale
        visualRoot.yScale = baseScale
        meowLabel.position = CGPoint(x: facingRight ? 54 * baseScale : -54 * baseScale, y: 82 * baseScale)
        meowLabel.setScale(baseScale)
    }
}
