import AppKit

final class PreferencesWindowController: NSWindowController {
    private let preferences: AppPreferences
    private let loginItemController = LoginItemController()
    private let onChange: () -> Void
    private let speedLabel = NSTextField(labelWithString: "")
    private let scaleLabel = NSTextField(labelWithString: "")
    private let speedSlider = NSSlider(value: 0, minValue: 30, maxValue: 180, target: nil, action: nil)
    private let scaleSlider = NSSlider(value: 0, minValue: 0.7, maxValue: 1.4, target: nil, action: nil)
    private let fullScreenCheckbox = NSButton(checkboxWithTitle: "在全屏空间显示小猫", target: nil, action: nil)
    private let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "开机自动启动", target: nil, action: nil)
    private let loginStatusLabel = NSTextField(labelWithString: "")

    init(preferences: AppPreferences, onChange: @escaping () -> Void) {
        self.preferences = preferences
        self.onChange = onChange

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 292),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "萌宠陪伴设置"
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)
        buildContent()
        refreshControls()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        refreshControls()
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func buildContent() {
        guard let contentView = window?.contentView else {
            return
        }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        stack.addArrangedSubview(makeSliderRow(title: "移动速度", label: speedLabel, slider: speedSlider))
        stack.addArrangedSubview(makeSliderRow(title: "小猫大小", label: scaleLabel, slider: scaleSlider))
        stack.addArrangedSubview(fullScreenCheckbox)
        stack.addArrangedSubview(launchAtLoginCheckbox)
        stack.addArrangedSubview(loginStatusLabel)

        speedSlider.target = self
        speedSlider.action = #selector(speedChanged)
        scaleSlider.target = self
        scaleSlider.action = #selector(scaleChanged)
        fullScreenCheckbox.target = self
        fullScreenCheckbox.action = #selector(fullScreenChanged)
        launchAtLoginCheckbox.target = self
        launchAtLoginCheckbox.action = #selector(launchAtLoginChanged)
        loginStatusLabel.textColor = .secondaryLabelColor
        loginStatusLabel.font = .systemFont(ofSize: 12)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        ])
    }

    private func makeSliderRow(title: String, label: NSTextField, slider: NSSlider) -> NSView {
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        label.alignment = .right
        label.widthAnchor.constraint(equalToConstant: 64).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 220).isActive = true

        let header = NSStackView(views: [titleLabel, label])
        header.orientation = .horizontal
        header.distribution = .fill
        header.spacing = 8
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)

        let row = NSStackView(views: [header, slider])
        row.orientation = .vertical
        row.alignment = .leading
        row.spacing = 8
        return row
    }

    private func refreshControls() {
        speedSlider.doubleValue = preferences.petSpeed
        scaleSlider.doubleValue = preferences.petScale
        fullScreenCheckbox.state = preferences.showInFullScreen ? .on : .off
        launchAtLoginCheckbox.state = loginItemController.isEnabled ? .on : .off
        speedLabel.stringValue = "\(Int(preferences.petSpeed)) px/s"
        scaleLabel.stringValue = "\(Int(preferences.petScale * 100))%"
        loginStatusLabel.stringValue = "登录项状态：\(loginItemController.statusDescription)"
    }

    @objc private func speedChanged() {
        preferences.petSpeed = speedSlider.doubleValue
        refreshControls()
        onChange()
    }

    @objc private func scaleChanged() {
        preferences.petScale = scaleSlider.doubleValue
        refreshControls()
        onChange()
    }

    @objc private func fullScreenChanged() {
        preferences.showInFullScreen = fullScreenCheckbox.state == .on
        refreshControls()
        onChange()
    }

    @objc private func launchAtLoginChanged() {
        do {
            try loginItemController.setEnabled(launchAtLoginCheckbox.state == .on)
        } catch {
            loginStatusLabel.stringValue = "登录项更新失败：\(error.localizedDescription)"
            launchAtLoginCheckbox.state = loginItemController.isEnabled ? .on : .off
            return
        }

        refreshControls()
    }
}
