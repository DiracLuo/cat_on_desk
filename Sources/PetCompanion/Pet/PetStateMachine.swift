import Foundation

enum PetState {
    case walking
    case idle
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
            transition(to: .walking, at: time)
        case .paused:
            break
        }
    }

    private func transition(to newState: PetState, at time: TimeInterval) {
        state = newState
        stateStartedAt = time

        switch newState {
        case .walking:
            nextTransitionAt = time + Double.random(in: 6...12)
        case .idle:
            nextTransitionAt = time + Double.random(in: 2...5)
        case .paused:
            nextTransitionAt = .infinity
        }
    }
}
