# Windows 版本实现记录

## 1. 当前状态

Windows 版本已基于 WPF 完成源码级实现：

```text
Windows/PetCompanion.Windows
```

当前开发环境是 macOS 且没有安装 `.NET SDK`，因此本轮未能在本机编译运行。需要在 Windows + .NET 8 环境下执行验证。

## 2. 目标

Windows 版本目标与 macOS 一致：

- 在任务栏上方出现一只可爱小猫。
- 小猫沿任务栏边缘移动。
- 默认不影响用户点击任务栏。
- 支持睡觉、倒地打滚、喵叫、鼠标靠近、单击、双击和拖拽互动。

## 3. 核心思路

不要修改 Windows 任务栏本身。

采用透明、无边框、置顶窗口覆盖在任务栏上方，视觉上让小猫像在任务栏边缘活动。

这与 macOS 方案一致：

```text
macOS Dock 上方透明窗口
Windows Taskbar 上方透明窗口
```

## 4. 技术栈

- C#。
- .NET 8 或更新版本。
- WPF。
- NotifyIcon 托盘入口。
- Win32 API 获取任务栏位置。

选择理由：

- WPF 做透明窗口和托盘工具成熟。
- Win32 API 获取任务栏位置可靠。
- 资源占用比 Electron 更适合常驻小工具。
- 后续打包成 MSIX 或普通安装包都可行。

本轮未采用的备选方案：

- WinUI 3：更现代，但透明无边框、托盘、置顶小工具细节会更绕。
- Avalonia：跨平台好，但 Windows 原生任务栏细节仍要 P/Invoke。
- Electron/Tauri：跨平台开发方便，但透明置顶窗口和常驻资源占用需要额外权衡。

## 5. 任务栏定位

Windows 可使用 Win32 API：

```text
SHAppBarMessage(ABM_GETTASKBARPOS)
```

返回 `APPBARDATA.rc`，可以知道任务栏矩形。

根据矩形判断任务栏位置：

- 底部：`rc.top` 接近屏幕底部。
- 顶部：`rc.bottom` 接近屏幕顶部。
- 左侧：`rc.right` 接近屏幕左侧。
- 右侧：`rc.left` 接近屏幕右侧。

窗口轨道：

- 底部任务栏：窗口放在任务栏上方。
- 顶部任务栏：窗口放在任务栏下方。
- 左侧任务栏：窗口放在任务栏右侧。
- 右侧任务栏：窗口放在任务栏左侧。

## 6. 透明窗口策略

WPF 可用：

- `WindowStyle=None`
- `AllowsTransparency=True`
- `Background=Transparent`
- `Topmost=True`
- `ShowInTaskbar=False`

点击穿透可通过 Win32 扩展样式：

```text
WS_EX_TRANSPARENT
WS_EX_LAYERED
WS_EX_TOOLWINDOW
```

鼠标互动阶段再动态切换穿透。

## 7. 动画方案

短期建议：

- 复用 macOS 的 PNG spritesheet。
- 用 WPF `Image` + `DispatcherTimer` 播放序列帧。

中期建议：

- 抽象宠物状态机和动画模型。
- 平台层只负责窗口、任务栏定位、托盘菜单。

结构建议：

```text
PetCompanion.Windows
├── App
├── Tray
├── Taskbar
├── OverlayWindow
├── Pet
│   ├── PetStateMachine
│   ├── PetMovementController
│   └── SpriteAnimationController
└── Preferences
```

## 8. 和 macOS 共享的部分

可共享概念：

- 状态机设计。
- 动作概率与冷却时间。
- 动画资产命名。
- 设置项。
- 产品节奏。

不建议早期强行共享源码。

原因：

- macOS 当前是 Swift。
- Windows 推荐 C#。
- 早期跨语言共享源码收益低，反而拖慢体验验证。

建议先共享文档、资产和状态机语义，等两个平台都稳定后再考虑公共配置格式。

## 9. Windows MVP 对照

### W1. WPF 项目骨架

交付：

- 托盘应用。
- 无普通主窗口。
- 可退出。

状态：已实现。

### W2. 任务栏检测

交付：

- 获取任务栏矩形。
- 判断任务栏边缘。
- 多显示器下定位到任务栏所在屏幕。

状态：已实现基础版本，需要 Windows 真机 QA。

### W3. 透明覆盖窗口

交付：

- 透明。
- 无边框。
- 置顶。
- 不出现在任务栏。
- 默认点击穿透。

状态：已实现。

### W4. 小猫显示与移动

交付：

- 显示占位猫。
- 沿任务栏边缘移动。
- 边界反弹。

状态：已实现，且行走范围限制在活动中心附近约三分之一屏幕宽度。

### W5. 托盘菜单与设置

交付：

- 暂停/恢复。
- 重新定位。
- 设置。
- 退出。

状态：已实现。

## 10. 风险点

多显示器：

- 任务栏可能只在主显示器，也可能每个显示器都有任务栏。
- 第一版优先跟随主任务栏。

DPI 缩放：

- Windows 多屏 DPI 可能不同。
- 需要使用 per-monitor DPI aware。

点击穿透：

- 要确保不影响任务栏点击。
- 鼠标互动要动态切换，不可长期阻挡。

置顶层级：

- 不能盖住系统关键 UI。
- 全屏游戏或视频时建议自动隐藏。

## 11. 下一步

Windows 端可行，源码已落地。下一步需要：

1. 在 Windows 机器安装 .NET 8 SDK。
2. 执行 `dotnet build -c Release`。
3. 运行并验证任务栏位置、透明点击穿透、拖拽、单击、双击和设置窗口。
4. 确认 exe 图标、托盘图标和发布目录资源复制。
5. 根据 QA 结果修正多屏和 DPI 场景。
