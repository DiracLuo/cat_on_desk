# 待提交变更

由于当前 Codex 沙箱仍无法写入 `.git/index.lock`，本轮变更尚未由 Codex 提交到 git。

用户回到电脑后建议执行：

```bash
cd /Users/dirac/code/萌宠陪伴
git add Makefile README.md \
  Sources/PetCompanion/App/AppController.swift \
  Sources/PetCompanion/App/StatusBarController.swift \
  Sources/PetCompanion/Pet/PetMovementController.swift \
  Sources/PetCompanion/Pet/PetScene.swift \
  Sources/PetCompanion/Platform/DockTracker.swift \
  Sources/PetCompanion/Platform/LoginItemController.swift \
  Sources/PetCompanion/Preferences/PreferencesWindowController.swift \
  Sources/PetCompanion/Window/PetWindowController.swift \
  docs/stage-1-mvp-progress.md \
  docs/productization-roadmap.md \
  docs/windows-pre-research.md \
  docs/pending-git-commit.md
git commit -m "Improve productization and Windows planning"
```

本轮主要变更：

- 修复多屏下小猫跟随 Dock 所在屏幕。
- 调整小猫落点，使其更贴近 Dock 上边缘。
- 增加 `make reveal`、`make install-user`、`make run-installed`。
- 增加设置面板。
- 增加开机自动启动入口。
- 增加 macOS 产品化路线文档。
- 增加 Windows 版本预研文档。
