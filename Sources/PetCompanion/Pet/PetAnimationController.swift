import Foundation

final class PetAnimationController {
    private let walkCycleDuration: TimeInterval = 0.72
    private let idleCycleDuration: TimeInterval = 2.4

    func walkingPhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: walkCycleDuration)) / walkCycleDuration
    }

    func idlePhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: idleCycleDuration)) / idleCycleDuration
    }
}
