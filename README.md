# 萌宠陪伴

一个 macOS 原生轻量桌面陪伴工具。当前版本会在 Dock 上方创建透明悬浮窗口，并显示一只会左右移动、待机眨眼的小猫。

## 当前状态

已完成第一阶段技术验证和 MVP 基础骨架：

- 菜单栏常驻应用。
- 透明无边框宠物窗口。
- Dock/屏幕可见区域推断定位。
- SpriteKit 透明场景。
- 程序化绘制小猫。
- 左右移动、边界转身。
- walking / idle / paused 基础状态机。
- 菜单栏暂停、恢复、重新定位、退出。
- `UserDefaults` 保存暂停状态、速度和尺寸等基础偏好。
- Makefile 生成 `.app` bundle。

## 构建

当前机器的 SwiftPM manifest 链接存在环境问题，因此优先使用 Makefile 进行本地构建：

```bash
make build
```

构建产物：

```text
.build/local/PetCompanion.app
```

## 运行

```bash
make run
```

或者在 Finder 中打开：

```text
.build/local/PetCompanion.app
```

应用启动后会以菜单栏工具形式运行，菜单栏图标为猫咪图标。

## 清理

```bash
make clean
```

## 重要说明

- 当前实现没有修改或嵌入 macOS Dock，只是在 Dock 上方显示透明覆盖窗口。
- 第一版默认 `ignoresMouseEvents = true`，避免影响 Dock 点击。
- Dock 定位基于 `NSScreen.frame` 和 `NSScreen.visibleFrame` 推断，底部 Dock 是主要验证目标。
- SwiftPM 的 `Package.swift` 已保留，后续本机 Xcode/CLT 环境修复后可继续使用标准 SwiftPM 工作流。

## 后续入口

完整开发计划见：

```text
docs/development-plan.md
```

阶段验证记录见：

```text
docs/stage-1-mvp-progress.md
```
