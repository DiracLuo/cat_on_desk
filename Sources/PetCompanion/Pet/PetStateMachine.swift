import Foundation

enum PetState {
    case walking
    case idle
    case looking
    case watching
    case sleeping
    case stretching
    case meowing
    case paused
}

final class PetStateMachine {
    private(set) var state: PetState = .walking
    private var previousActiveState: PetState = .walking
    private var stateStartedAt: TimeInterval = 0
    private var nextTransitionAt: TimeInterval = 6

    var isPaused: Bool {
        state == .paused
    }

    var isSleeping: Bool {
        state == .sleeping
    }

    func setPaused(_ paused: Bool, at time: TimeInterval) {
        if paused {
            if state != .paused {
                previousActiveState = state
                transition(to: .paused, at: time)
            }
        } else if state == .paused {
            transition(to: previousActiveState, at: time)
        }
    }

    func update(at time: TimeInterval) {
        guard state != .paused, time >= nextTransitionAt else {
            return
        }

        switch state {
        case .walking:
            transition(to: .idle, at: time)
        case .idle:
            transition(to: nextIdleTransition(), at: time)
        case .looking:
            transition(to: .walking, at: time)
        case .watching:
            nextTransitionAt = .infinity
        case .sleeping, .stretching, .meowing:
            transition(to: .walking, at: time)
        case .paused:
            break
        }
    }

    func setWatching(_ watching: Bool, at time: TimeInterval) {
        guard state != .paused else {
            return
        }

        if watching {
            if state == .walking || state == .idle {
                transition(to: .watching, at: time)
            }
        } else if state == .watching {
            transition(to: .walking, at: time)
        }
    }

    func triggerClickReaction(at time: TimeInterval) {
        guard state != .paused else {
            return
        }

        let reaction: PetState = Bool.random() ? .meowing : .stretching
        transition(to: reaction, at: time)
    }

    func triggerSleep(at time: TimeInterval) {
        guard state != .paused else {
            return
        }

        if state == .sleeping {
            transition(to: .walking, at: time)
        } else {
            transition(to: .sleeping, at: time)
        }
    }

    private func nextIdleTransition() -> PetState {
        let roll = Double.random(in: 0...1)
        if roll < 0.20 {
            return .looking
        }
        if roll < 0.38 {
            return .sleeping
        }
        if roll < 0.56 {
            return .stretching
        }
        if roll < 0.72 {
            return .meowing
        }
        return .walking
    }

    private func transition(to newState: PetState, at time: TimeInterval) {
        state = newState
        stateStartedAt = time

        switch newState {
        case .walking:
            nextTransitionAt = time + Double.random(in: 4...9)
        case .idle:
            nextTransitionAt = time + Double.random(in: 1.5...4)
        case .looking:
            nextTransitionAt = time + Double.random(in: 2...4)
        case .watching:
            nextTransitionAt = .infinity
        case .sleeping:
            nextTransitionAt = time + Double.random(in: 7...14)
        case .stretching:
            nextTransitionAt = time + 2.4
        case .meowing:
            nextTransitionAt = time + 2.0
        case .paused:
            nextTransitionAt = .infinity
        }
    }
}
