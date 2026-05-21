# 萌宠陪伴 Mac 工具开发计划

## 1. 项目目标

“萌宠陪伴”是一款常驻 macOS 桌面的轻量陪伴工具。第一版目标是在 Mac 程序坞上方出现一只可爱的小猫，小猫可以沿着程序坞上方的水平线来回走动，在用户工作时提供低打扰、轻松、治愈的陪伴感。

项目后续会扩展更多宠物动作与互动，例如睡觉、伸懒腰、喵叫、被点击后的反馈、情绪变化、用户偏好设置，以及 Windows 端版本。

核心原则：

- 轻量：常驻运行时 CPU、内存、能耗都应保持较低。
- 低打扰：默认不影响用户点击 Dock、切换应用、全屏工作。
- 可爱但克制：动作有陪伴感，但不频繁打断用户。
- 原生优先：第一阶段优先使用 macOS 原生能力，保证体验稳定。
- 可扩展：宠物动作、状态机、资产、平台能力要为后续扩展留出空间。

## 2. 产品范围

### 2.1 MVP 范围

MVP 只验证最关键体验：

- 应用启动后，在 Dock 上方显示一只小猫。
- 小猫沿 Dock 上方水平区域左右移动。
- 小猫移动到边界后自动转身。
- 小猫有基础行走动画。
- 应用可从菜单栏暂停、恢复和退出。
- 默认尽量不阻挡用户点击 Dock。

### 2.2 暂不进入 MVP 的功能

以下功能不进入第一阶段，避免过早复杂化：

- 睡觉、伸懒腰、喵叫等复杂动作。
- 点击抚摸、拖拽、投喂等互动。
- 多宠物。
- 宠物商店、皮肤系统。
- 云同步。
- Windows 端。
- App Store 发布、自动更新、崩溃上报。

这些功能会作为后续阶段规划。

## 3. 技术架构决策

### 3.1 首选技术栈

第一版采用：

- Swift
- AppKit
- SpriteKit
- Swift Package Manager 或 Xcode 原生项目结构

选择理由：

- AppKit 对透明窗口、无边框窗口、菜单栏应用、窗口层级控制支持最直接。
- SpriteKit 适合 2D 精灵动画、时间驱动更新、简单状态机与移动逻辑。
- Swift 原生应用体积小、启动快、能耗更容易控制。
- 后续打包、签名、公证、开机启动等 macOS 工程能力更顺滑。

### 3.2 暂不选择的方案

Electron：

- 优点是跨平台和前端开发友好。
- 缺点是体积和资源占用偏大，对一个常驻小工具来说不够轻。

Flutter：

- 优点是跨平台 UI 能力强。
- 缺点是透明置顶窗口、鼠标穿透、Dock 贴合等原生细节仍需平台通道处理。

Unity：

- 优点是动画和游戏能力强。
- 缺点是运行时过重，不适合一个轻量常驻桌面工具。

Tauri：

- 优点比 Electron 轻。
- 缺点是 macOS 原生窗口细节仍要额外处理，第一版不如 AppKit 直接。

结论：第一阶段使用 Swift + AppKit + SpriteKit。等 macOS MVP 跑通后，再考虑是否抽象跨平台核心逻辑，为 Windows 端复用。

## 4. 系统设计

### 4.1 总体结构

```text
PetCompanion
├── App
│   ├── AppDelegate
│   ├── AppController
│   └── StatusBarController
│
├── Platform
│   ├── DockTracker
│   ├── ScreenObserver
│   └── WindowLevelPolicy
│
├── Window
│   ├── PetWindowController
│   └── PetOverlayWindow
│
├── Pet
│   ├── PetScene
│   ├── PetNode
│   ├── PetStateMachine
│   ├── PetMovementController
│   └── PetAnimationController
│
├── Assets
│   ├── CatSprites
│   └── Sounds
│
└── Preferences
    ├── AppPreferences
    └── PreferenceStore
```

### 4.2 模块职责

AppDelegate：

- 应用生命周期入口。
- 初始化主控制器。
- 配置菜单栏应用行为。

AppController：

- 组合各模块。
- 启动/停止宠物窗口。
- 响应菜单栏命令。

StatusBarController：

- 创建菜单栏图标。
- 提供暂停、恢复、退出等操作。
- 后续扩展设置入口。

DockTracker：

- 根据 `NSScreen.frame` 和 `NSScreen.visibleFrame` 推断 Dock 占用区域。
- 计算宠物窗口应放置的位置。
- 第一阶段只强支持 Dock 位于屏幕底部。
- 后续支持左侧、右侧、自动隐藏与多显示器。

ScreenObserver：

- 监听屏幕参数变化。
- 监听应用激活、显示器插拔、分辨率变化。
- 触发布局刷新。

PetOverlayWindow：

- 透明、无边框、不透明度为 0 背景的窗口。
- 放置在 Dock 上方。
- 默认尽量不抢焦点。
- 支持鼠标穿透策略。

PetWindowController：

- 创建并管理 `PetOverlayWindow`。
- 挂载 SpriteKit `SKView`。
- 根据 DockTracker 的结果调整窗口位置和尺寸。

PetScene：

- SpriteKit 主场景。
- 维护帧更新。
- 放置猫咪节点。
- 协调动作、移动和边界检测。

PetNode：

- 猫咪视觉节点。
- 持有当前方向、尺寸、动画纹理。

PetStateMachine：

- 管理宠物状态。
- 第一阶段包含 `walking`、`paused`。
- 后续扩展 `idle`、`sleeping`、`stretching`、`meowing`、`reacting`。

PetMovementController：

- 控制速度、方向、边界反弹。
- 将逻辑坐标转换为场景坐标。

PetAnimationController：

- 加载 spritesheet 或纹理序列。
- 播放行走动画。
- 根据方向翻转猫咪。

PreferenceStore：

- 使用 `UserDefaults` 保存基础设置。
- 第一阶段保存暂停状态、速度、猫咪尺寸等可选项。

### 4.3 窗口策略

宠物不是嵌入 Dock，而是显示在 Dock 上方的透明覆盖窗口中。

第一阶段窗口策略：

- 使用 borderless `NSPanel` 或 `NSWindow`。
- `isOpaque = false`。
- `backgroundColor = .clear`。
- `hasShadow = false`。
- `ignoresMouseEvents = true` 作为默认行为。
- 窗口层级初步使用 `.floating` 或 `.statusBar`，以实际验证为准。
- 不让窗口出现在 Dock 或 Cmd+Tab 中。

后续根据实际体验微调：

- 当鼠标靠近猫咪时关闭穿透，用于点击互动。
- 全屏应用下可选择隐藏。
- 自动隐藏 Dock 时可选择跟随隐藏或保持显示。

### 4.4 Dock 定位策略

macOS 没有公开 API 可以把普通 App 安全地嵌入 Dock。第一阶段采用推断策略：

- 获取主屏幕 `NSScreen.main`。
- 使用 `screen.frame` 获取完整屏幕区域。
- 使用 `screen.visibleFrame` 获取去掉菜单栏和 Dock 后的可见区域。
- 当 Dock 位于底部时，`frame.minY` 到 `visibleFrame.minY` 的差值可近似表示 Dock 占用高度。
- 宠物轨道放置在 `visibleFrame.minY` 上方一小段区域。

第一阶段假设：

- Dock 位于屏幕底部。
- 使用主屏幕。
- 不处理自动隐藏 Dock 的复杂过渡。

需要在技术验证中确认：

- 不同 Dock 尺寸下的视觉位置。
- 外接显示器时窗口是否出现在预期屏幕。
- Dock 自动隐藏开启时的表现。
- 刘海屏、不同分辨率、缩放设置下的位置偏差。

### 4.5 动画资产策略

第一阶段使用 PNG 序列帧：

```text
Assets/CatSprites/walk_00.png
Assets/CatSprites/walk_01.png
Assets/CatSprites/walk_02.png
Assets/CatSprites/walk_03.png
```

建议规格：

- 单帧透明 PNG。
- 猫咪视觉尺寸约 64-120 px，根据 Dock 大小调整。
- 第一版行走动画 4-8 帧即可。
- 所有帧保持相同画布尺寸，避免播放时抖动。

后续可选：

- 使用 Texture Atlas 优化加载。
- 使用 Rive 或 Spine 处理更流畅骨骼动画。
- 增加动作包，例如 idle、sleep、stretch、meow。

### 4.6 状态机设计

第一阶段：

```text
paused <-> walking
```

第二阶段扩展：

```text
walking -> idle -> walking
idle -> sleeping -> waking -> idle
idle -> stretching -> walking
idle -> meowing -> idle
clicked -> reacting -> idle
```

状态设计原则：

- 每个状态只负责自己的进入、更新、退出。
- 动作间切换通过状态机统一管理。
- 随机动作需要冷却时间，避免频繁打扰用户。
- 音效默认关闭或低频触发。

### 4.7 设置与持久化

第一阶段可只做最小设置：

- 是否暂停。
- 移动速度。
- 猫咪尺寸。

使用 `UserDefaults` 保存。

后续设置：

- 开机启动。
- 是否在全屏应用上显示。
- 是否启用音效。
- 喵叫频率。
- 宠物活跃程度。
- 选择宠物外观。

## 5. 阶段路线图

### 阶段 0：项目初始化

目标：建立可编译、可运行的 macOS 项目骨架。

交付物：

- Xcode/macOS App 项目。
- 基础目录结构。
- 应用启动入口。
- 菜单栏入口。
- 空白透明窗口验证。

### 阶段 1：技术验证版

目标：证明“Dock 上方透明窗口 + 小猫移动”方案可行。

交付物：

- 透明覆盖窗口出现在 Dock 上方。
- 一张临时猫咪图片在窗口内左右移动。
- 到达边界自动转身。
- 默认不影响 Dock 点击。
- 菜单栏可暂停/恢复/退出。

### 阶段 2：MVP

目标：形成第一个可长期运行的可爱版本。

交付物：

- 行走序列帧动画。
- 稳定的窗口定位。
- 基础状态机。
- 用户偏好持久化。
- 初步能耗优化。
- 基础测试和手工 QA 清单。

### 阶段 3：陪伴感增强

目标：让小猫从“移动贴图”变成有生命感的陪伴角色。

交付物：

- idle 动作。
- sleep 动作。
- stretch 动作。
- meow 动作与可关闭音效。
- 随机事件调度。
- 点击反馈。

### 阶段 4：产品化

目标：让应用具备可分发能力。

交付物：

- 应用图标。
- 设置窗口。
- 开机启动。
- 签名、公证。
- DMG 打包。
- 自动更新方案评估。
- 崩溃日志与匿名诊断方案评估。

### 阶段 5：Windows 版本预研

目标：验证 Windows 端任务栏上方陪伴方案。

交付物：

- Windows 透明窗口技术验证。
- 任务栏位置检测。
- 跨平台核心逻辑抽象。
- 资产复用方案。

## 6. 第一阶段详细拆解

第一阶段定义为“技术验证版”，目标是用最小工程量证明核心体验可行。

### 6.1 第一阶段目标

完成一个可运行的 macOS App：

- 启动后没有普通主窗口。
- 菜单栏出现应用入口。
- Dock 上方出现透明宠物活动区域。
- 小猫在该区域内水平移动。
- 小猫碰到左右边界后转身。
- 暂停后小猫停止移动。
- 退出菜单能关闭应用。

### 6.2 第一阶段非目标

第一阶段不处理：

- 精美角色设计。
- 多动作动画。
- 音效。
- 设置面板。
- 多显示器完整适配。
- Dock 左侧/右侧完整适配。
- 自动隐藏 Dock 的完美跟随。
- Windows 端。

### 6.3 任务拆解

#### T1. 创建 macOS 项目骨架

内容：

- 创建 macOS App 项目。
- 使用 Swift。
- 最低系统版本建议先设为 macOS 13 或 macOS 14，后续根据需求下探。
- 配置应用为菜单栏常驻形态。
- 移除默认主窗口或启动后隐藏默认窗口。

验收标准：

- 应用可以编译运行。
- 启动后不会弹出无关主窗口。
- 应用生命周期可正常进入和退出。

#### T2. 实现菜单栏控制

内容：

- 创建 `StatusBarController`。
- 菜单项包含：
  - 暂停/恢复
  - 重新定位
  - 退出
- 菜单栏图标可先使用系统符号或临时图标。

验收标准：

- 菜单栏显示应用图标。
- 点击菜单栏图标能看到菜单。
- 退出菜单能关闭应用。
- 暂停/恢复菜单能切换内部状态。

#### T3. 创建透明覆盖窗口

内容：

- 创建 `PetOverlayWindow`。
- 设置透明背景、无边框、无阴影。
- 设置不抢焦点。
- 设置默认鼠标穿透。
- 将窗口显示到屏幕底部区域。

验收标准：

- 窗口背景不可见。
- 窗口没有标题栏和边框。
- 用户仍可点击 Dock 图标。
- 应用不干扰正常窗口切换。

#### T4. 实现 DockTracker 初版

内容：

- 获取主屏幕 `NSScreen.main`。
- 读取 `frame` 与 `visibleFrame`。
- 推断 Dock 底部高度。
- 计算宠物窗口 frame：
  - x：主屏幕左侧。
  - y：Dock 上方附近。
  - width：主屏幕宽度。
  - height：猫咪活动高度，例如 140 px。

验收标准：

- Dock 位于底部时，宠物活动区域出现在 Dock 上方。
- 改变 Dock 尺寸后，点击“重新定位”可以更新位置。
- 菜单栏不影响底部定位计算。

#### T5. 接入 SpriteKit 场景

内容：

- 在透明窗口中放置 `SKView`。
- 创建 `PetScene`。
- 场景背景透明。
- 场景尺寸跟随窗口尺寸。

验收标准：

- `SKView` 不显示背景色。
- 场景内容可以正常渲染。
- 调整窗口 frame 后场景尺寸正确。

#### T6. 显示临时猫咪节点

内容：

- 添加 `PetNode`。
- 第一版可使用临时 PNG 或简单占位图。
- 猫咪位置贴近活动区域底部。
- 设置合适尺寸。

验收标准：

- 应用启动后能看到猫咪。
- 猫咪不会被 Dock 遮挡。
- 猫咪不会离 Dock 太远。

#### T7. 实现左右移动和边界反弹

内容：

- 创建 `PetMovementController`。
- 设置水平速度。
- 每帧更新 x 坐标。
- 到达左/右边界后反向。
- 反向时水平翻转猫咪。

验收标准：

- 猫咪可以平滑左右移动。
- 到达边界后不会消失。
- 转身方向正确。
- 暂停后停止移动，恢复后继续移动。

#### T8. 基础行走动画

内容：

- 准备临时行走序列帧。
- 创建 `PetAnimationController`。
- 播放循环 walk 动画。
- 移动暂停时动画也暂停或切换为静止帧。

验收标准：

- 猫咪移动时有行走动画。
- 动画循环没有明显跳帧。
- 左右方向切换时动画仍正常。

#### T9. 屏幕变化与重新定位

内容：

- 监听 `NSApplication.didChangeScreenParametersNotification`。
- 当屏幕变化时重新计算 Dock 和窗口位置。
- 菜单提供手动“重新定位”命令。

验收标准：

- 分辨率变化后可以重新定位。
- 外接显示器插拔后不崩溃。
- 手动重新定位可用。

#### T10. 第一阶段 QA 与问题记录

内容：

- 建立手工 QA 清单。
- 记录不同 Dock 设置下的表现。
- 记录性能观察。
- 记录第一阶段遗留问题。

验收标准：

- 有明确 QA 结果。
- 已知问题被记录。
- 能判断是否进入 MVP 阶段。

### 6.4 第一阶段建议开发顺序

```text
T1 项目骨架
T2 菜单栏控制
T3 透明覆盖窗口
T4 DockTracker 初版
T5 SpriteKit 场景
T6 临时猫咪节点
T7 移动与边界反弹
T8 行走动画
T9 屏幕变化与重新定位
T10 QA 与问题记录
```

### 6.5 第一阶段文件建议

```text
PetCompanion/
├── App/
│   ├── AppDelegate.swift
│   ├── AppController.swift
│   └── StatusBarController.swift
│
├── Platform/
│   ├── DockTracker.swift
│   └── ScreenObserver.swift
│
├── Window/
│   ├── PetWindowController.swift
│   └── PetOverlayWindow.swift
│
├── Pet/
│   ├── PetScene.swift
│   ├── PetNode.swift
│   ├── PetMovementController.swift
│   └── PetAnimationController.swift
│
└── Assets.xcassets/
    └── CatSprites
```

### 6.6 第一阶段里程碑

Milestone A：窗口验证

- 菜单栏应用可运行。
- 透明窗口显示在 Dock 上方。
- 不影响 Dock 点击。

Milestone B：宠物显示

- SpriteKit 场景透明渲染。
- 临时猫咪显示在正确位置。

Milestone C：宠物移动

- 猫咪可以左右移动。
- 边界转身正常。
- 暂停/恢复正常。

Milestone D：技术验证完成

- 行走动画可用。
- 重新定位可用。
- QA 清单完成。
- 形成是否进入 MVP 的判断。

### 6.7 第一阶段风险与验证点

窗口层级风险：

- `.floating` 可能在部分场景被普通窗口盖住。
- `.statusBar` 可能过于靠前，影响体验。
- 需要实测不同全屏、分屏、普通桌面场景。

鼠标穿透风险：

- 全局穿透会导致第一阶段无法点击猫咪。
- 第一阶段可以接受，因为点击互动不是目标。
- 后续可实现鼠标靠近猫咪时局部响应。

Dock 定位风险：

- `visibleFrame` 推断对底部 Dock 通常可用，但不是正式 Dock API。
- 自动隐藏 Dock 时可能不稳定。
- 第一阶段需记录表现，不追求完美。

能耗风险：

- SpriteKit 持续 60 FPS 可能不必要。
- 第一阶段先跑通，MVP 阶段再限制帧率或在静止状态降低更新频率。

资产风险：

- 临时图可能不可爱，影响直觉判断。
- 第一阶段只验证技术，可在 Milestone B 后替换更合适素材。

### 6.8 第一阶段测试清单

基础运行：

- 应用能启动。
- 应用能退出。
- 菜单栏菜单可用。
- 暂停/恢复可用。

窗口表现：

- 背景透明。
- 无边框。
- 不抢焦点。
- 不出现在 Cmd+Tab 中，若产品决定如此。
- 不影响点击 Dock。

定位表现：

- 默认 Dock 尺寸下位置正确。
- 放大 Dock 后位置可重新计算。
- 缩小 Dock 后位置可重新计算。
- 菜单栏存在时不影响底部定位。

动画表现：

- 猫咪能显示。
- 猫咪能移动。
- 左右边界转身正常。
- 移动时动画流畅。
- 暂停时移动停止。

稳定性：

- 连续运行 30 分钟不崩溃。
- 睡眠唤醒后不崩溃。
- 外接显示器插拔后不崩溃。
- 分辨率变化后可手动重新定位。

性能：

- 空闲 CPU 占用保持较低。
- 内存占用稳定。
- 不明显影响风扇和电池。

## 7. MVP 阶段预案

当第一阶段通过后，进入 MVP 阶段。

MVP 重点：

- 将临时素材替换为正式可爱猫咪动画。
- 引入更完整状态机。
- 加入 idle 状态。
- 增加用户偏好保存。
- 优化帧率与能耗。
- 完善多屏场景。
- 建立最小自动化测试。

MVP 验收标准：

- 可以作为日常常驻工具使用。
- 不明显干扰用户工作。
- 小猫有基本生命感。
- 至少连续运行 4 小时稳定。
- 常见 Dock 配置下位置合理。

## 8. 后续跨平台架构预留

为了未来 Windows 端，建议把核心逻辑和平台逻辑分离。

可抽象接口：

```text
PetRuntime
├── PetStateMachine
├── PetMovementController
├── PetAnimationModel
└── RandomEventScheduler

PlatformRuntime
├── macOS DockTracker
├── macOS OverlayWindow
├── Windows TaskbarTracker
└── Windows OverlayWindow
```

短期不需要为了跨平台牺牲 macOS 体验。第一版代码可以先保持直接清晰，等状态机和动画逻辑稳定后再抽象。

## 9. 工程约定

### 9.1 代码风格

- Swift 类型名使用 UpperCamelCase。
- 方法和属性使用 lowerCamelCase。
- 每个模块职责保持单一。
- 避免过早抽象。
- 复杂行为写少量必要注释。

### 9.2 分支建议

初期可以使用简单分支：

- `main`：稳定可运行版本。
- `feature/stage-1-prototype`：第一阶段开发。
- `feature/mvp-animation`：MVP 动画增强。

### 9.3 版本建议

- `0.1.0`：第一阶段技术验证版。
- `0.2.0`：MVP 可日常使用版。
- `0.3.0`：多动作陪伴版。
- `1.0.0`：可分发稳定版。

## 10. 当前下一步

当前阶段 0、阶段 1 和 MVP 基础骨架已经开始实现。最新进度见：

```text
docs/stage-1-mvp-progress.md
```

后续建议继续：

1. 使用 `.app` bundle 做可视化运行验证。
2. 调整 Dock 上方窗口高度和猫咪落点。
3. 替换正式猫咪动作素材。
4. 增加设置窗口。
5. 完善多屏、自动隐藏 Dock 和长期能耗测试。

完成这些后，就能判断这个产品最关键的技术路径是否成立。
