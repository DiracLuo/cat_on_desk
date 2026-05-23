# 待提交变更

当前本地已有待提交变更。建议将构建输出 `dist/` 作为本地发布产物，不再纳入 git。

用户回到电脑后建议执行：

```bash
cd /Users/dirac/code/萌宠陪伴
git add .gitignore Makefile README.md Resources Sources Tools docs Windows
git status --short
git commit -m "Harden 1.0.0 release packaging"
git push origin main
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
- 生成本地 1.0.0 ZIP 发布包和 SHA256 校验文件。
- 增加 Windows WPF 对应实现。
- 增加整只小猫暖橙应用图标，并接入 macOS app bundle、Windows exe 和托盘图标。
- 让 `make package` 自动刷新 ZIP 的 SHA256 校验文件。
- 移除当前环境无法重新生成的旧 DMG 发布产物，避免误发过期包。
- 打包时对 macOS `.app` 做 ad-hoc 签名并验证资源 seal。
- 从 git 索引移除 `dist/`，发布包改走 GitHub Releases 或其他 artifact 存储。
- 明确猫咪精灵 PNG、AppIcon PNG/ICNS、Windows ICO 是当前版本化产品资产。
- 记录下一轮工程优化：动作定义单一来源、移动边界去重、依赖注入和轻量测试。
