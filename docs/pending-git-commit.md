# 待提交变更

由于当前 Codex 沙箱仍无法写入 `.git/index.lock`，本轮变更尚未由 Codex 提交到 git。

用户回到电脑后建议执行：

```bash
cd /Users/dirac/code/萌宠陪伴
git add .gitignore Makefile README.md Resources Sources Tools docs dist Windows
git commit -m "Release 1.0.0 and add Windows version"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

本轮主要变更：

- 修复多屏下小猫跟随 Dock 所在屏幕。
- 调整小猫落点，使其更贴近 Dock 上边缘。
- 增加 `make reveal`、`make install-user`、`make run-installed`。
- 增加设置面板。
- 增加开机自动启动入口。
- 增加 PNG 猫咪精灵素材管线。
- 增加睡觉、倒地打滚、喵喵叫动作。
- 增加鼠标靠近、单击、双击互动。
- 增加拖拽设置活动中心和三分之一屏宽巡游范围。
- 将旧的占位动作替换为倒地打滚。
- 增加 Dock 自动跟随轮询，将手动菜单改为“立即校准 Dock”。
- 增加 macOS 产品化路线文档。
- 增加 Windows 版本预研文档。
- 更新版本号到 `1.0.0`。
- 生成 1.0.0 ZIP 发布包和 SHA256 校验文件。
- 增加 Windows WPF 对应实现。
- 增加整只小猫暖橙应用图标，并接入 macOS app bundle、Windows exe 和托盘图标。
- 让 `make package` 自动刷新 ZIP 的 SHA256 校验文件。
- 移除当前环境无法重新生成的旧 DMG 发布产物，避免误发过期包。
- 打包时对 macOS `.app` 做 ad-hoc 签名并验证资源 seal。
