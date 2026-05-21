import AppKit

final class StatusBarController {
    private let preferences: AppPreferences
    private let onTogglePause: () -> Void
    private let onRelocate: () -> Void
    private let onQuit: () -> Void
    private var statusItem: NSStatusItem?

    init(
        preferences: AppPreferences,
        onTogglePause: @escaping () -> Void,
        onRelocate: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.preferences = preferences
        self.onTogglePause = onTogglePause
        self.onRelocate = onRelocate
        self.onQuit = onQuit
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item
        item.button?.title = "🐱"
        refresh()
    }

    func uninstall() {
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }

    func refresh() {
        let menu = NSMenu()
        let pauseTitle = preferences.isPaused ? "恢复小猫" : "暂停小猫"
        menu.addItem(NSMenuItem(title: pauseTitle, action: #selector(togglePause), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "重新定位", action: #selector(relocate), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出萌宠陪伴", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem?.menu = menu
    }

    @objc private func togglePause() {
        onTogglePause()
    }

    @objc private func relocate() {
        onRelocate()
    }

    @objc private func quit() {
        onQuit()
    }
}
