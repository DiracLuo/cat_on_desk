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
        onOpenPreferences: { [weak self] in self?.openPreferences() },
        onQuit: { NSApp.terminate(nil) }
    )
    private lazy var preferencesWindowController = PreferencesWindowController(
        preferences: preferences,
        onChange: { [weak self] in
            self?.petWindowController.preferencesDidChange()
        }
    )
    private var dockFollowTimer: Timer?

    func start() {
        statusBarController.install()
        petWindowController.show()
        petWindowController.setPaused(preferences.isPaused)
        screenObserver.start()
        startDockFollowTimer()
    }

    func stop() {
        stopDockFollowTimer()
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
        petWindowController.reposition(force: true)
    }

    private func openPreferences() {
        preferencesWindowController.show()
    }

    private func startDockFollowTimer() {
        dockFollowTimer?.invalidate()
        dockFollowTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.petWindowController.repositionIfNeeded()
        }
        dockFollowTimer?.tolerance = 0.6
    }

    private func stopDockFollowTimer() {
        dockFollowTimer?.invalidate()
        dockFollowTimer = nil
    }
}
