# Windows 版本预研

## 1. 目标

Windows 版本目标与 macOS 一致：

- 在任务栏上方出现一只可爱小猫。
- 小猫沿任务栏边缘移动。
- 默认不影响用户点击任务栏。
- 后续支持睡觉、伸懒腰、喵叫和点击互动。

## 2. 核心思路

不要修改 Windows 任务栏本身。

采用透明、无边框、置顶窗口覆盖在任务栏上方，视觉上让小猫像在任务栏边缘活动。

这与 macOS 方案一致：

```text
macOS Dock 上方透明窗口
Windows Taskbar 上方透明窗口
```

## 3. 推荐技术栈

优先方案：

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

备选方案：

- WinUI 3：更现代，但透明无边框、托盘、置顶小工具细节会更绕。
- Avalonia：跨平台好，但 Windows 原生任务栏细节仍要 P/Invoke。
- Electron/Tauri：跨平台开发方便，但透明置顶窗口和常驻资源占用需要额外权衡。

## 4. 任务栏定位

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

## 5. 透明窗口策略

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

## 6. 动画方案

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

## 7. 和 macOS 共享的部分

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

## 8. Windows MVP 任务拆解

### W1. WPF 项目骨架

交付：

- 托盘应用。
- 无普通主窗口。
- 可退出。

### W2. 任务栏检测

交付：

- 获取任务栏矩形。
- 判断任务栏边缘。
- 多显示器下定位到任务栏所在屏幕。

### W3. 透明覆盖窗口

交付：

- 透明。
- 无边框。
- 置顶。
- 不出现在任务栏。
- 默认点击穿透。

### W4. 小猫显示与移动

交付：

- 显示占位猫。
- 沿任务栏边缘移动。
- 边界反弹。

### W5. 托盘菜单与设置

交付：

- 暂停/恢复。
- 重新定位。
- 设置。
- 退出。

## 9. 风险点

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

## 10. 建议结论

Windows 端可行。

推荐路线：

1. 先继续打磨 macOS，尤其是正式猫咪素材和互动体验。
2. macOS MVP 稳定后，用 C# WPF 做 Windows 技术验证。
3. 共享动画资产、动作语义和产品设置，不强行共享 Swift/C# 源码。
