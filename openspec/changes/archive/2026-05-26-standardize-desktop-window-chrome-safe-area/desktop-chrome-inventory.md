## Desktop Chrome Inventory

本清单记录本 change 实施时看到的 desktop window / shell root 与 `desktop-window-chrome-safe-area` 的关系。目标是确认哪些 surface 需要共享 safe-area seam，哪些 surface 可以明确排除，避免后续靠单页 magic padding 修补 macOS traffic lights 重叠。

| Surface | 当前窗口/chrome 模型 | Safe-area 状态 | 本 change 处理 |
| --- | --- | --- | --- |
| Main macOS shell (`AppleMacosPageShell`) | macOS full-size / transparent titlebar，Flutter 内容进入 titlebar 区域 | 已消费 `resolveDesktopWindowChromeInsets` 和 `resolveMacosTrafficLightCompensation` | 保持现状，补 guardrail 防回退 |
| Memos macOS desktop titlebar | 主窗口内 memo quick-action titlebar | 已通过 `kMacosTrafficLightReservedWidth` 常量引用集中 seam | 保持现状，禁止重新引入本地数值 |
| Desktop settings window (`DesktopSettingsWindowApp`) | 独立设置窗口，左上标题靠近 macOS traffic lights | 已消费 `resolveDesktopWindowChromeInsets` | 保持设置页体验，不做视觉重构 |
| Desktop share task window (`DesktopShareTaskWindowApp` / `ShareClipScreen`) | 新增 one-shot task window，root title 可能进入 macOS traffic lights 区域 | 实施前未消费 shared safe-area；截图暴露重叠 | 本 change 首个迁移对象：通过 shared opt-in shell 接入 |
| Stats screen (`StatsScreen`) | 数据统计页可作为 desktop secondary page 或设置入口打开，标题/返回位于顶部 leading 区域 | 实施前未显式 opt-in `PlatformPage.desktopWindowChromeSafeArea` | 本 change 扩展消费方：通过 `PlatformPage.desktopWindowChromeSafeArea` 接入 |
| Sync queue screen (`SyncQueueScreen`) | 同步队列页可由 macOS menu、drawer 或统计页打开，顶部标题/返回/同步按钮靠近 window chrome | 实施前使用页面内 `Scaffold` / `AppBar`，未消费 `PlatformPage` safe-area seam | 本 change 扩展消费方：desktop 分支迁到 `PlatformPage.desktopWindowChromeSafeArea`，mobile 分支保留既有 Material scaffold |
| Notifications screen (`NotificationsScreen`) | 消息通知页可作为 desktop secondary page 或导航入口打开，标题/返回位于顶部 leading 区域 | 非 Windows 分支使用 `PlatformPage`，实施前未显式 opt-in desktop chrome safe-area | 本 change 扩展消费方：通过 `PlatformPage.desktopWindowChromeSafeArea` 接入；Windows `DesktopShellHost` 保持现状 |
| Desktop quick input window | Windows 上 frameless resize frame；非 Windows 不绘制 top-leading titlebar content | 不需要 macOS traffic-light inset | 明确排除，保持现状 |
| Login/onboarding titlebar | 主窗口登录页自绘 titlebar action | 已消费 `resolveDesktopWindowChromeInsets` | 保持现状 |
| 普通 feature `PlatformPage` | Material/Cupertino 页面壳，通常不假设进入 native titlebar | 默认不应用 desktop chrome inset | 新增 opt-in 参数，仅 task window/root 需要时打开 |

## Notes

- 本 change 不触碰 API 相关文件。
- 本 change 不重新设计 settings page/window；设置窗口只作为“不回退”验证对象。
- 新增 desktop task window root 时，应优先复用 `PlatformPage.desktopWindowChromeSafeArea` 或后续统一的 `DesktopTaskWindowShell`，而不是在 feature page 内写 traffic-light padding。
- 数据统计、同步队列、消息通知这类已暴露/高风险 secondary pages 已纳入同一 seam；后续若发现其他页面有相同 top-leading overlap，应继续接入共享 seam，而不是新增页面级常量。
