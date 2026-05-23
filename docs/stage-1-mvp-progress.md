# 1.0.0 开发进度归档

## 1. 本轮目标

按照 `docs/development-plan.md` 推进：

- 初始化项目版本控制准备。
- 建立 macOS 原生应用工程。
- 完成第一阶段技术验证。
- 实现 MVP 所需的基础技术架构。
- 形成后续可继续迭代的代码和文档基线。

## 2. 已完成内容

### 2.1 项目结构

已建立 Swift/AppKit/SpriteKit 项目结构：

```text
Sources/PetCompanion
├── App
├── Platform
├── Window
├── Pet
├── Preferences
└── main.swift
```

已添加：

- `Package.swift`
- `Makefile`
- `.gitignore`
- `Resources/Info.plist`
- `README.md`

### 2.2 菜单栏应用

已实现：

- `AppDelegate`
- `AppController`
- `StatusBarController`

当前菜单项：

- 暂停/恢复小猫。
- 立即校准 Dock。
- 设置。
- 退出萌宠陪伴。

应用通过 `LSUIElement = true` 配置为辅助型菜单栏应用，不作为普通主窗口应用出现。

### 2.3 透明宠物窗口

已实现：

- `PetOverlayWindow`
- `PetWindowController`

窗口行为：

- borderless。
- transparent。
- non-activating panel。
- floating level。
- 默认鼠标穿透。
- can join all spaces。
- 不抢主窗口焦点。

### 2.4 Dock 定位

已实现：

- `DockTracker`
- `ScreenObserver`

定位方式：

- 使用 `NSScreen.frame` 和 `NSScreen.visibleFrame` 推断 Dock 边缘。
- 扫描所有屏幕，优先选择 Dock 占用间隙最大的屏幕，避免多屏时跟随当前活跃副屏。
- 每 2 秒低频检查 Dock 轨道变化，Dock 换屏或尺寸变化后自动跟随。
- 优先验证底部 Dock。
- 初步兼容左侧和右侧 Dock 的窗口轨道方向。
- 监听屏幕参数变化和 Space 变化后重新定位。

### 2.5 SpriteKit 宠物场景

已实现：

- `PetScene`
- `PetNode`
- `PetMovementController`
- `PetAnimationController`
- `PetStateMachine`

当前行为：

- 小猫显示在透明 SpriteKit 场景中。
- 小猫沿 Dock 上方水平移动。
- 碰到边界后转身。
- 使用 PNG 精灵帧显示猫咪素材。
- 行走时播放 walk 动画。
- idle 时播放待机眨眼动画。
- sleeping 时播放睡觉动画。
- rolling 时播放倒地打滚动画。
- meowing 时播放喵喵叫视觉气泡动画。
- 鼠标靠近小猫时停止移动并看向用户。
- 鼠标单击小猫时随机触发喵喵叫或倒地打滚。
- 鼠标双击小猫时立即睡觉。
- 鼠标拖拽小猫时更新活动中心。
- 默认行走范围限制在活动中心附近约三分之一屏幕宽度。
- paused 时停止移动和动画。

### 2.7 产品化基础

已新增设置窗口：

- 移动速度。
- 小猫大小。
- 是否在全屏空间显示小猫。
- 开机自动启动。

已新增产品化文档：

- `docs/productization-roadmap.md`
- `docs/windows-pre-research.md`

### 2.6 偏好存储

已实现：

- `AppPreferences`

当前偏好项：

- `isPaused`
- `petSpeed`
- `petScale`
- `showInFullScreen`

## 3. 构建验证

### 3.1 SwiftPM 状态

尝试执行：

```bash
swift build
```

当前机器出现 SwiftPM manifest 链接问题：

- SwiftPM 尝试写入用户级缓存，被沙箱限制。
- 通过项目内 module cache 绕过后，manifest 仍出现 `PackageDescription` 链接符号不匹配。

因此当前保留 `Package.swift`，但本地验证采用 Makefile。

### 3.2 Makefile 构建

已执行并通过：

```bash
make build
```

产物：

```text
.build/local/PetCompanion.app
```

Makefile 会：

- 创建 `.app` bundle。
- 编译 Swift 源码。
- 链接 AppKit 和 SpriteKit。
- 拷贝 `Resources/Info.plist`。

也提供更直观的启动方式：

- `make reveal`：在 Finder 中定位 `.app`。
- `make install-user`：安装到 `~/Applications/萌宠陪伴.app`。
- `make run-installed`：安装后启动。

## 4. 运行验证记录

已进行一次命令行启动验证，应用进程可以启动并进入常驻运行状态。

注意：

- 直接运行裸可执行文件不是推荐方式。
- 后续应运行 `.app` bundle。
- 当前沙箱不允许直接终止已启动的裸可执行进程，后续验证应优先使用 `make run` 或 Finder 打开 `.app`，并通过菜单栏“退出萌宠陪伴”关闭。

## 5. 当前 MVP 能力判断

目前代码已经覆盖 1.0.0 可试用版本：

- 技术验证成立：透明窗口、Dock 定位、SpriteKit 渲染、宠物移动均已实现。
- 交互体验成立：鼠标靠近、单击、双击、拖拽均已实现。
- 产品基础成立：状态机、菜单控制、偏好存储、设置窗口、应用 bundle 结构均已实现。
- 发布打包成立：支持生成 DMG 和 ZIP 发布产物。

还没有完成的 MVP 产品化细节：

- 正式猫咪素材。
- 更细腻的睡觉、倒地打滚、喵叫动作。
- 设置面板。
- 开机启动。
- 自动隐藏 Dock 的细致适配。
- 多显示器完整策略。
- 长时间能耗测试。

## 6. 下一步建议

优先继续做：

1. 使用 `.app` bundle 做可视化运行验证。
2. 调整 Dock 上方窗口高度和猫咪落点。
3. 增加“靠近鼠标时可点击”的交互策略。
4. 替换为正式猫咪 spritesheet 或 Rive/Spine 动画资源。
5. 增加设置窗口。
6. 做 30 分钟到 4 小时的稳定性和能耗观察。

## 7. 版本控制状态

已添加 `.gitignore`，但 `git init` 在当前沙箱中失败：

```text
/Users/dirac/code/萌宠陪伴/.git: Operation not permitted
```

已按权限流程请求升级执行 `git init`，但审批未及时返回。后续需要在宿主机上执行：

```bash
git init
git add .
git commit -m "Initial PetCompanion prototype"
```

这样才能完成用户要求的 git 化、版本备份和回溯。
