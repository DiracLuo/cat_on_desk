# 萌宠陪伴

一个 macOS 原生轻量桌面陪伴工具。当前版本会在 Dock 上方创建透明悬浮窗口，并显示一只会左右移动、待机眨眼的小猫。

## 当前状态

当前已发布 `1.0.0` 可试用版本：

- 菜单栏常驻应用。
- 透明无边框宠物窗口。
- Dock 所在屏幕自动跟随。
- SpriteKit 透明场景。
- PNG 精灵帧小猫。
- 左右移动、边界转身。
- walking / idle / watching / sleeping / rolling / meowing / paused 状态机。
- 鼠标靠近后小猫会停下看你。
- 鼠标单击小猫会随机喵喵叫或打滚。
- 鼠标双击小猫会睡觉，再次双击会恢复。
- 鼠标拖拽小猫可以调整它的活动中心。
- 小猫默认围绕活动中心在约三分之一屏宽内来回走动。
- 菜单栏暂停、恢复、立即校准 Dock、退出。
- 菜单栏设置面板，可调整速度、大小和全屏空间显示。
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

## 打包

生成 1.0.0 发布包：

```bash
make package
```

发布产物：

```text
dist/1.0.0/萌宠陪伴-1.0.0.zip
```

如果当前 macOS 环境允许 `hdiutil` 创建设备映像，也会额外生成：

```text
dist/1.0.0/萌宠陪伴-1.0.0.dmg
```

## 运行

开发时可以直接运行：

```bash
make run
```

或者在 Finder 中打开：

```text
.build/local/PetCompanion.app
```

应用启动后会以菜单栏工具形式运行，菜单栏图标为猫咪图标。点击菜单栏猫咪图标可以打开设置、暂停、立即校准 Dock 或退出。

小猫会自动跟随 Dock 所在屏幕和 Dock 上边缘位置。“立即校准 Dock”只是手动兜底项，它不是把小猫重置到起点，主要用于系统通知延迟或 Dock 状态异常时强制重新计算位置。

也可以打开构建产物所在目录，然后在 Finder 里双击：

```bash
make reveal
```

更接近日常使用的方式是安装到当前用户的 Applications 目录：

```bash
make install-user
```

之后可以从 Finder、Spotlight 或启动台打开“萌宠陪伴”。也可以一步完成安装并启动：

```bash
make run-installed
```

## 退出

优先点击菜单栏的猫咪图标，然后选择“退出萌宠陪伴”。

也可以在终端执行：

```bash
make quit
```

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

产品化路线见：

```text
docs/productization-roadmap.md
```

Windows 预研见：

```text
docs/windows-pre-research.md
```

阶段验证记录见：

```text
docs/stage-1-mvp-progress.md
```
