import AppKit
import SpriteKit

final class PetNode: SKNode {
    private let visualRoot = SKNode()
    private let body = SKShapeNode()
    private let head = SKShapeNode()
    private let tail = SKShapeNode()
    private let frontLeg = SKShapeNode()
    private let backLeg = SKShapeNode()
    private let leftEye = SKShapeNode(circleOfRadius: 2.3)
    private let rightEye = SKShapeNode(circleOfRadius: 2.3)
    private let mouth = SKShapeNode()
    private var baseScale: CGFloat = 1
    private var facingRight = true

    var petSize: CGSize {
        CGSize(width: 104 * baseScale, height: 84 * baseScale)
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
        let wave = CGFloat(sin(phase * .pi * 2))
        let counterWave = CGFloat(sin((phase + 0.5) * .pi * 2))
        visualRoot.position.y = 3 + abs(wave) * 2.2
        frontLeg.zRotation = wave * 0.18
        backLeg.zRotation = counterWave * 0.18
        tail.zRotation = 0.24 + wave * 0.12
        head.position.y = 28 + abs(counterWave) * 1.4
        setEyesOpen(true)
    }

    func applyIdle(phase: Double) {
        let breath = CGFloat(sin(phase * .pi * 2))
        visualRoot.position.y = 3 + breath * 0.9
        frontLeg.zRotation = 0
        backLeg.zRotation = 0
        tail.zRotation = 0.18 + breath * 0.04
        head.position.y = 28 + breath * 0.6
        setEyesOpen(!(phase > 0.46 && phase < 0.54))
    }

    func applyPaused() {
        visualRoot.position.y = 3
        frontLeg.zRotation = 0
        backLeg.zRotation = 0
        tail.zRotation = 0.18
        setEyesOpen(true)
    }

    private func build() {
        removeAllChildren()
        addChild(visualRoot)
        visualRoot.position = CGPoint(x: 0, y: 3)

        let bodyPath = CGPath(
            roundedRect: CGRect(x: -38, y: -14, width: 76, height: 42),
            cornerWidth: 22,
            cornerHeight: 22,
            transform: nil
        )
        body.path = bodyPath
        body.fillColor = NSColor(calibratedRed: 1.0, green: 0.72, blue: 0.42, alpha: 1)
        body.strokeColor = NSColor(calibratedRed: 0.38, green: 0.22, blue: 0.12, alpha: 1)
        body.lineWidth = 2
        body.position = CGPoint(x: -2, y: 7)
        visualRoot.addChild(body)

        head.path = CGPath(ellipseIn: CGRect(x: -21, y: -17, width: 42, height: 38), transform: nil)
        head.fillColor = NSColor(calibratedRed: 1.0, green: 0.76, blue: 0.46, alpha: 1)
        head.strokeColor = body.strokeColor
        head.lineWidth = 2
        head.position = CGPoint(x: 31, y: 28)
        visualRoot.addChild(head)

        addEar(at: CGPoint(x: 19, y: 45), flipped: false)
        addEar(at: CGPoint(x: 42, y: 44), flipped: true)
        addFace()
        addLegs()
        addTail()
        addStripes()
        applyFacing()
        applyIdle(phase: 0)
    }

    private func addEar(at position: CGPoint, flipped: Bool) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: flipped ? -10 : 10, y: 19))
        path.addLine(to: CGPoint(x: flipped ? -18 : 18, y: -1))
        path.closeSubpath()

        let ear = SKShapeNode(path: path)
        ear.fillColor = NSColor(calibratedRed: 1.0, green: 0.69, blue: 0.42, alpha: 1)
        ear.strokeColor = body.strokeColor
        ear.lineWidth = 2
        ear.position = position
        visualRoot.addChild(ear)
    }

    private func addFace() {
        for eye in [leftEye, rightEye] {
            eye.fillColor = NSColor(calibratedWhite: 0.08, alpha: 1)
            eye.strokeColor = .clear
            head.addChild(eye)
        }
        leftEye.position = CGPoint(x: -7, y: 3)
        rightEye.position = CGPoint(x: 8, y: 3)

        let nose = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -3, y: -2, width: 6, height: 4), transform: nil))
        nose.fillColor = NSColor(calibratedRed: 0.75, green: 0.29, blue: 0.31, alpha: 1)
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 1, y: -4)
        head.addChild(nose)

        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: 1, y: -6))
        mouthPath.addQuadCurve(to: CGPoint(x: -8, y: -9), control: CGPoint(x: -4, y: -12))
        mouthPath.move(to: CGPoint(x: 1, y: -6))
        mouthPath.addQuadCurve(to: CGPoint(x: 10, y: -9), control: CGPoint(x: 6, y: -12))
        mouth.path = mouthPath
        mouth.strokeColor = NSColor(calibratedRed: 0.35, green: 0.18, blue: 0.13, alpha: 1)
        mouth.lineWidth = 1.4
        head.addChild(mouth)
    }

    private func addLegs() {
        frontLeg.path = legPath()
        backLeg.path = legPath()

        for leg in [frontLeg, backLeg] {
            leg.fillColor = NSColor(calibratedRed: 0.96, green: 0.62, blue: 0.33, alpha: 1)
            leg.strokeColor = body.strokeColor
            leg.lineWidth = 1.8
            visualRoot.addChild(leg)
        }

        frontLeg.position = CGPoint(x: 18, y: -10)
        backLeg.position = CGPoint(x: -23, y: -10)
    }

    private func legPath() -> CGPath {
        CGPath(
            roundedRect: CGRect(x: -5, y: -19, width: 10, height: 24),
            cornerWidth: 5,
            cornerHeight: 5,
            transform: nil
        )
    }

    private func addTail() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -34, y: 14))
        path.addCurve(
            to: CGPoint(x: -59, y: 39),
            control1: CGPoint(x: -50, y: 17),
            control2: CGPoint(x: -60, y: 25)
        )
        path.addCurve(
            to: CGPoint(x: -47, y: 48),
            control1: CGPoint(x: -58, y: 47),
            control2: CGPoint(x: -52, y: 50)
        )
        tail.path = path
        tail.strokeColor = body.strokeColor
        tail.lineWidth = 9
        tail.lineCap = .round
        tail.zPosition = -2
        visualRoot.addChild(tail)
    }

    private func addStripes() {
        let stripeColor = NSColor(calibratedRed: 0.7, green: 0.38, blue: 0.18, alpha: 1)
        for x in [-18, 0, 18] {
            let stripe = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 24))
            path.addLine(to: CGPoint(x: x - 4, y: 14))
            stripe.path = path
            stripe.strokeColor = stripeColor
            stripe.lineWidth = 2
            stripe.lineCap = .round
            body.addChild(stripe)
        }
    }

    private func setEyesOpen(_ open: Bool) {
        let scaleY: CGFloat = open ? 1 : 0.18
        leftEye.yScale = scaleY
        rightEye.yScale = scaleY
    }

    private func applyFacing() {
        visualRoot.xScale = (facingRight ? 1 : -1) * baseScale
        visualRoot.yScale = baseScale
    }
}
