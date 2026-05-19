# macOS 手工验收步骤

## 目的

确认公共 macOS shell 的菜单、快捷键、窗口行为和商业边界符合 Apple 平台体验预期。以下步骤覆盖 Flutter widget / architecture tests 难以可靠断言的系统级行为。

## 步骤

1. 在 macOS 上启动应用，确认主窗口仍使用系统窗口框架，窗口关闭、最小化、缩放和全屏按钮由系统标题栏提供，应用内容区不显示 Windows 风格窗口控制。
2. 打开应用菜单，确认包含 About、Settings、Services、Hide、Hide Others、Show All、Quit，并且 Settings 能打开设置窗口或设置入口。
3. 打开 Window 菜单，确认包含 Close、Minimize、Zoom、Enter Full Screen、Bring All to Front、Open Settings Window、Focus Quick Input。
4. 验证常用快捷键：Command+N 新建 memo，Command+Shift+N 快速输入，Command+F 搜索，Command+Comma 设置，Command+W 关闭窗口，Command+M 最小化，Control+Command+F 全屏。
5. 从 Memo、Sync、AI、Tools、Help 菜单触发主要命令，确认能够打开对应页面、设置窗口或外部帮助链接，并且不会出现 Windows shell 导航或 Android drawer-first 呈现。
6. 关闭最后一个窗口，确认行为符合当前 `applicationShouldTerminateAfterLastWindowClosed` 策略；重新启动后确认窗口恢复不会破坏首页 shell、侧栏和工具栏布局。
7. 检查菜单、设置入口、首页 shell 和平台 adapter 中没有 StoreKit、订阅、买断、价格、receipt、paywall、TestFlight、App Store Connect、签名密钥或 notarization 发布自动化相关 UI / 文案 / 配置。

## 通过标准

- macOS 使用独立 Apple desktop shell、系统窗口控制、菜单栏命令和 Apple 风格 toolbar / sidebar。
- iOS / iPadOS / macOS 不需要复制 feature 页面树；业务页面、状态管理和 public/private extension seam 继续复用。
- 公共仓不新增商业运行时逻辑或 App Store 发布自动化配置。
