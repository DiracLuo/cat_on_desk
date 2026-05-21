import Foundation

final class AppPreferences {
    private enum Keys {
        static let isPaused = "isPaused"
        static let petSpeed = "petSpeed"
        static let petScale = "petScale"
        static let showInFullScreen = "showInFullScreen"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    var isPaused: Bool {
        get { defaults.bool(forKey: Keys.isPaused) }
        set { defaults.set(newValue, forKey: Keys.isPaused) }
    }

    var petSpeed: Double {
        get { defaults.double(forKey: Keys.petSpeed) }
        set { defaults.set(newValue, forKey: Keys.petSpeed) }
    }

    var petScale: Double {
        get { defaults.double(forKey: Keys.petScale) }
        set { defaults.set(newValue, forKey: Keys.petScale) }
    }

    var showInFullScreen: Bool {
        get { defaults.bool(forKey: Keys.showInFullScreen) }
        set { defaults.set(newValue, forKey: Keys.showInFullScreen) }
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.isPaused: false,
            Keys.petSpeed: 82.0,
            Keys.petScale: 1.0,
            Keys.showInFullScreen: false
        ])
    }
}
