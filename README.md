# 萌宠陪伴

一个 macOS 原生轻量桌面陪伴工具。当前版本会在 Dock 上方创建透明悬浮窗口，并显示一只会左右移动、待机眨眼的小猫。

## 下载安装使用

当前推荐通过 GitHub Releases 下载应用，不需要自己编译。

### 1. 下载 ZIP

打开发布页：

```text
https://github.com/DiracLuo/cat_on_desk/releases
```

在最新版本的 `Assets` 区域下载：

```text
萌宠陪伴-1.0.0.zip
```

不要下载 `Source code (zip)` 或 `Source code (tar.gz)`，那是源码包，不是可直接运行的应用。

### 2. 安装应用

下载后双击 `萌宠陪伴-1.0.0.zip` 解压，会得到：

```text
萌宠陪伴.app
```

建议把 `萌宠陪伴.app` 拖到：

```text
应用程序 / Applications
```

然后在 Finder、启动台或 Spotlight 中打开“萌宠陪伴”。

### 3. 首次打开授权

当前版本未做 Apple Developer ID 公证，macOS 首次打开时可能会拦截，这是正常现象。

推荐方式：

1. 在 Finder 中找到 `萌宠陪伴.app`。
2. 按住 `Control` 并点击应用，或右键点击应用。
3. 选择“打开”。
4. 在弹窗中再次选择“打开”。

如果仍然被拦截：

1. 打开“系统设置”。
2. 进入“隐私与安全性”。
3. 在安全提示区域点击“仍要打开”或“允许打开”。

如果 macOS 提示应用“已损坏”或无法打开，并且你确认 ZIP 来自本项目 GitHub Releases，可以在终端执行：

```bash
xattr -dr com.apple.quarantine /Applications/萌宠陪伴.app
```

然后再次打开应用。

### 4. 使用和退出

打开后，小猫会出现在 Dock 上方，并自动跟随 Dock 所在屏幕。应用是菜单栏小工具，不会在 Dock 中显示普通应用图标。

点击屏幕顶部菜单栏里的猫咪图标，可以打开设置、暂停/恢复、立即校准 Dock 或退出。

鼠标互动：

- 鼠标靠近小猫：小猫会停下来看你。
- 单击小猫：随机喵喵叫或倒地打滚。
- 双击小猫：进入睡觉；再次双击恢复。
- 拖拽小猫：调整它的活动中心。

当前 `1.0.0` 发布包由 Apple Silicon Mac 构建，主要面向 Apple Silicon 设备。Intel Mac 如无法运行，可先尝试本地构建，或等待后续 universal 版本。

## 当前状态

当前已发布 `1.0.0` 可试用版本：

- 菜单栏常驻应用。
- 透明无边框宠物窗口。
- Dock 所在屏幕自动跟随。
- SpriteKit 透明场景。
- PNG 精灵帧小猫。
- 整只小猫暖橙应用图标，已接入 macOS app bundle 和 Windows 工程。
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

`dist/` 是本地构建输出目录，不进入 git 版本控制。正式对外分发时，将 ZIP 和 `SHA256SUMS` 上传到 GitHub Releases 或其他 artifact 存储。

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
- `Resources/CatSprites/*.png`、`Resources/AppIcon.png`、`Resources/AppIcon.icns` 和 `Windows/PetCompanion.Windows/app.ico` 是当前 1.0 版本化产品资产。生成脚本用于重建这些资产，但中间目录不入库。
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

Windows 源码实现见：

```text
Windows/PetCompanion.Windows
```

阶段验证记录见：

```text
docs/stage-1-mvp-progress.md
```
