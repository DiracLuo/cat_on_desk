import Foundation

final class PetAnimationController {
    private let walkCycleDuration: TimeInterval = 0.72
    private let idleCycleDuration: TimeInterval = 2.4
    private let sleepCycleDuration: TimeInterval = 2.8
    private let stretchCycleDuration: TimeInterval = 2.4
    private let meowCycleDuration: TimeInterval = 1.0

    func walkingPhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: walkCycleDuration)) / walkCycleDuration
    }

    func idlePhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: idleCycleDuration)) / idleCycleDuration
    }

    func sleepPhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: sleepCycleDuration)) / sleepCycleDuration
    }

    func stretchPhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: stretchCycleDuration)) / stretchCycleDuration
    }

    func meowPhase(at time: TimeInterval) -> Double {
        (time.truncatingRemainder(dividingBy: meowCycleDuration)) / meowCycleDuration
    }
}
