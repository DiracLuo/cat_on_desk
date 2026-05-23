# 萌宠陪伴 Windows 版

这是 macOS `1.0.0` 功能的一比一 Windows/WPF 实现。

## 技术栈

- C#
- .NET 8
- WPF
- Windows Forms `NotifyIcon`
- Win32 API:
  - `SHAppBarMessage(ABM_GETTASKBARPOS)`
  - 扩展窗口样式 `WS_EX_TRANSPARENT` / `WS_EX_LAYERED` / `WS_EX_TOOLWINDOW`

## 已实现功能

- 托盘常驻入口。
- 透明、无边框、置顶宠物窗口。
- 默认鼠标穿透。
- 靠近小猫后临时接收鼠标事件。
- 自动检测任务栏位置，并覆盖任务栏所在屏幕。
- 小猫默认贴近任务栏边缘。
- 小猫围绕活动中心在约三分之一屏幕宽度内走动。
- 鼠标靠近后小猫停下看你。
- 单击小猫随机触发喵喵叫或倒地打滚。
- 双击小猫睡觉，再次双击恢复。
- 拖拽小猫到屏幕任意位置，并更新活动中心。
- 托盘菜单：
  - 暂停/恢复
  - 立即校准任务栏
  - 设置
  - 退出
- 设置窗口：
  - 移动速度
  - 小猫大小
  - 在全屏空间显示小猫
  - 开机自动启动
- 复用 macOS 版 `Resources/CatSprites` PNG 精灵帧。
- 使用同一套整只小猫暖橙应用图标，已接入 exe 和托盘图标。

## 构建

需要 Windows 和 .NET 8 SDK。

```powershell
cd Windows\PetCompanion.Windows
dotnet build -c Release
```

## 运行

```powershell
dotnet run -c Release
```

或者运行构建产物：

```powershell
bin\Release\net8.0-windows\PetCompanion.Windows.exe
```

## 发布

单文件发布示例：

```powershell
dotnet publish -c Release -r win-x64 --self-contained false
```

发布目录：

```text
Windows\PetCompanion.Windows\bin\Release\net8.0-windows\win-x64\publish
```

## 当前限制

- 当前开发环境是 macOS，未安装 `dotnet`，因此本轮只能完成源码级实现，不能在当前机器上编译运行 Windows 版。
- Windows 多任务栏/每屏任务栏的复杂场景仍需要真机 QA。
- Windows 打包产物需要在真机上确认 exe 图标、托盘图标和发布目录资源复制。
