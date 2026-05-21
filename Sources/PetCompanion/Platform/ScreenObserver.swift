import AppKit

final class ScreenObserver {
    private let onChange: () -> Void
    private var defaultCenterTokens: [NSObjectProtocol] = []
    private var workspaceCenterTokens: [NSObjectProtocol] = []

    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
    }

    func start() {
        let defaultCenter = NotificationCenter.default
        let workspaceCenter = NSWorkspace.shared.notificationCenter

        defaultCenterTokens.append(
            defaultCenter.addObserver(
                forName: NSApplication.didChangeScreenParametersNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.onChange()
            }
        )
        workspaceCenterTokens.append(
            workspaceCenter.addObserver(
                forName: NSWorkspace.activeSpaceDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.onChange()
            }
        )
    }

    func stop() {
        for token in defaultCenterTokens {
            NotificationCenter.default.removeObserver(token)
        }
        for token in workspaceCenterTokens {
            NSWorkspace.shared.notificationCenter.removeObserver(token)
        }
        defaultCenterTokens.removeAll()
        workspaceCenterTokens.removeAll()
    }
}
