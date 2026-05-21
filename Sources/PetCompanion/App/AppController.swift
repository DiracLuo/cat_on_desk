import AppKit

final class AppController {
    private let preferences = AppPreferences()
    private let dockTracker = DockTracker()
    private lazy var petWindowController = PetWindowController(
        dockTracker: dockTracker,
        preferences: preferences
    )
    private lazy var screenObserver = ScreenObserver { [weak self] in
        self?.relocatePetWindow()
    }
    private lazy var statusBarController = StatusBarController(
        preferences: preferences,
        onTogglePause: { [weak self] in self?.togglePause() },
        onRelocate: { [weak self] in self?.relocatePetWindow() },
        onQuit: { NSApp.terminate(nil) }
    )

    func start() {
        statusBarController.install()
        petWindowController.show()
        petWindowController.setPaused(preferences.isPaused)
        screenObserver.start()
    }

    func stop() {
        screenObserver.stop()
        petWindowController.close()
        statusBarController.uninstall()
    }

    private func togglePause() {
        preferences.isPaused.toggle()
        petWindowController.setPaused(preferences.isPaused)
        statusBarController.refresh()
    }

    private func relocatePetWindow() {
        petWindowController.reposition()
    }
}
