# macOS 产品化路线

## 1. 当前产品化进度

当前版本已经进入 `1.0.0` 可试用发布：

- `.app` bundle 构建。
- 本地 DMG/ZIP 打包流程。
- 菜单栏常驻。
- Dock 跟随定位。
- Dock 换屏和尺寸变化的自动跟随。
- 小猫移动和基础状态机。
- PNG 精灵素材管线。
- 睡觉、倒地打滚、喵喵叫视觉动作。
- 鼠标靠近、单击、双击互动。
- 鼠标拖拽设置活动中心。
- 小范围巡游，而不是横跨整屏。
- 设置面板。
- 开机启动入口。
- 用户偏好持久化。
- 安装到 `~/Applications` 的 Makefile 入口。

## 2. 本轮已推进事项

### 2.1 设置面板

已新增菜单栏“设置...”入口。

当前支持：

- 移动速度。
- 小猫大小。
- 是否在全屏空间显示小猫。
- 开机自动启动。

实现文件：

```text
Sources/PetCompanion/Preferences/PreferencesWindowController.swift
```

### 2.2 Dock 贴边体验

已调整：

- 透明窗口高度从 150 降到 118。
- 小猫底部落点降低，视觉上更贴近 Dock 上边缘。
- 多屏时扫描所有屏幕，选择真正有 Dock 间隙的屏幕。

### 2.3 启动方式

当前支持：

```bash
make run
make reveal
make install-user
make run-installed
```

推荐用户试用方式：

```bash
make install-user
```

之后从 Finder、Spotlight 或启动台打开“萌宠陪伴”。

## 3. 下一批产品化任务

### P1. 正式猫咪素材接入

目标：

- 用正式 PNG spritesheet 替换程序化绘制小猫。
- 保留当前 `PetNode` 作为 fallback。

建议任务：

- 建立资源目录或 asset catalog。
- 支持 walk / idle 两组动画。
- 统一帧尺寸，避免动画抖动。
- 增加素材加载失败时的 fallback。

验收标准：

- 小猫比当前绘制版更可爱。
- 动作循环稳定。
- 方向翻转不穿帮。

### P2. 签名与公证

目标：

- 让发布包具备更好的 macOS 打开体验。

建议任务：

- 申请或配置 Apple Developer 证书。
- 使用 Developer ID 签名。
- 执行 notarization。
- stapler 绑定公证结果。

### P3. 开机启动验证

目标：

- 验证设置面板中的“开机自动启动”在安装版 `.app` 中表现稳定。

当前实现：

- macOS 13+ 使用 `SMAppService.mainApp`。
- 需要以 `.app` bundle 方式运行。
- 设置面板显示登录项状态。

风险：

- 非签名开发包在不同系统设置下可能表现不同。
- 需要在真机上手动验证“登录项”是否出现。

### P3. 退出与进程管理优化

目标：

- 确保菜单退出、`make quit`、系统退出都稳定。

建议任务：

- 运行 `.app` bundle 后验证 `make quit`。
- 避免再直接运行裸可执行文件。
- 在 README 中明确推荐启动路径。

### P4. 多屏和 Dock 自动隐藏验证

目标：

- 小猫始终跟随 Dock 所在屏幕。
- Dock 自动隐藏时行为可配置。

建议策略：

- 默认跟随 `visibleFrame`。
- 增加“重新定位”手动兜底。
- 自动隐藏 Dock 场景先记录，再决定是否做轮询或事件监听。

### P5. 设置面板完善

目标：

- 让设置真正像小工具产品，而不是调试面板。

建议增加：

- 音效开关。
- 活跃程度。
- 是否全屏显示。
- 宠物尺寸预设。
- 恢复默认设置。

### P6. 仓库与发布物分离

当前策略：

- `dist/` 只作为本地构建输出，不进入 git。
- 1.0 版本化产品资产保留在仓库中，包括猫咪精灵 PNG、AppIcon PNG/ICNS 和 Windows ICO。
- 对外发布 ZIP、SHA256SUMS、未来 DMG 时，使用 GitHub Releases 或其他 artifact 存储。

## 4. 体验增强任务

### E1. 动作状态扩展

建议顺序：

1. idle。
2. sleep。
3. rolling。
4. meow。
5. clicked reaction。

状态机原则：

- 动作有冷却时间。
- 喵叫默认低频。
- 音效默认可关闭。

### E4. 工程优化待办

来自 1.0 发布前审查，下一轮建议优先处理：

- 统一 `PetAnimation` 和素材生成脚本中的动作定义，避免两处维护帧数。
- 提取 `PetMovementController` 中重复的边界约束逻辑。
- 评估将 `CatSpriteLibrary` 从全局单例调整为依赖注入。
- 为状态机和移动边界补充轻量单元测试。
- 后续准备正式 Bundle Identifier、Developer ID 签名和公证流程。

### E2. 鼠标互动

目标：

- 平时不影响 Dock 点击。
- 鼠标靠近小猫时可以点击互动。

建议方案：

- 继续默认 `ignoresMouseEvents = true`。
- 定时读取鼠标位置。
- 鼠标进入猫咪区域时短暂关闭穿透。
- 离开后恢复穿透。

风险：

- 鼠标穿透切换要非常克制，避免影响 Dock。

### E3. 能耗优化

建议：

- idle/sleep 状态降低帧率。
- 长时间不可见时暂停渲染。
- 检查 CPU、GPU 和闲置唤醒。

验收标准：

- 常驻 4 小时稳定。
- 空闲 CPU 占用低。
- 不造成明显风扇或电池影响。

## 5. 分发准备

后续正式分发需要：

- App 图标。
- Bundle identifier 定稿。
- Apple Developer 账号。
- 签名。
- 公证。
- DMG 打包。
- 自动更新方案评估。

自动更新可选：

- Sparkle。
- 自研 GitHub Releases 检查。

第一版建议先手动分发 DMG，不急着做自动更新。
