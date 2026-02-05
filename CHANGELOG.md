# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-02-05

### Added
- **Core**: 实现了基于 Accessibility (AX) 的智能选区触发，支持大多数 macOS 应用。
- **Core**: 新增 AX 失败时的兜底策略（模拟 Cmd+C），支持微信等非标准 App 的文本获取。
- **UI**: 全新设计的 MVP 浮窗操作条，支持悬停效果与自适应定位（鼠标/选区跟随）。
- **UI**: 完整的偏好设置面板（通用、操作、关于），支持自定义触发规则与外观。
- **Feature**: 集成 5 大基础动作：
  - 复制（Copy）：支持剪贴板历史恢复，防止非复制操作污染剪贴板。
  - 搜索（Search）：调用默认浏览器搜索选中文本。
  - 翻译（Bob）：深度集成 Bob 翻译（支持 Standard/Setapp/Legacy 多版本自动检测）。
  - 打开链接（Open Link）：智能识别 URL 文本并打开。
  - LocalRAG Hub：支持通过模拟快捷键唤起 LocalRAG Hub。
- **System**: 支持开机自启动（Launch Agent 方案）。
- **System**: 状态栏菜单常驻，支持快速访问设置、重启与退出。
- **System**: 支持点击 App 图标（Dock/Launchpad）直接唤起设置窗口（即使在无 Dock 模式下）。
- **Dev**: 新增 `build_app.sh` 一键打包脚本。

### Changed
- **UX**: 优化了触发门槛，将拖拽阈值调整为 3.0，平衡了误触与短文本选区的识别。
- **UX**: 强制使用 `.accessory` 激活策略（无 Dock 图标），保持纯净的后台运行体验。
- **UX**: 优化了 AppIcon 尺寸（1024px），修复了构建时的尺寸警告。
- **Core**: 优化了 AX 选区获取的重试逻辑与错误处理，大幅提升稳定性。

### Fixed
- 修复了在非文本区域（如窗口标题栏）点击误触发浮窗的问题。
- 修复了微信等 Electron/非原生应用无法触发选区的问题。
- 修复了关闭菜单栏图标后无法重新打开设置窗口的问题（现在可以通过再次点击 App 图标唤起）。
- 修复了 Bob 翻译调用时的权限与路径查找问题。

## [1.0.0] - 2026-02-02

### Added
- 初始项目骨架搭建。
- 基础的 Accessibility 权限引导。
