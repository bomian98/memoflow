## 1. 状态机与测试 seam

- [x] 1.1 梳理 `DesktopWindowManager` 现有 sub-window visibility 状态流，确认 `setSubWindowVisibility`、`scheduleVisibilitySync`、`_syncDesktopSubWindowVisibility`、`focusVisibleSubWindow` 的调用边界。
- [x] 1.2 为 `DesktopWindowManager` 增加最小可测试 sub-window client seam 或测试辅助入口，使 Dart tests 能 fake `getAllSubWindowIds`、visibility query、ping/focus/show 行为。
- [x] 1.3 添加 focused unit tests，覆盖 tracked id 被 native close 移除后 `_desktopVisibleSubWindowIds` 被清理且 `shouldBlurMainWindow` 变为 false。

## 2. 主窗口可见性 reconciliation

- [x] 2.1 调整 `DesktopWindowManager.scheduleVisibilitySync` 或相关调度逻辑，使 blur 状态下即使没有新的 Flutter build 也能在短延迟后校验 stale sub-window id。
- [x] 2.2 收紧 `_syncDesktopSubWindowVisibility`：当 `DesktopMultiWindow.getAllSubWindowIds()` 不包含 tracked id，或 `desktop.subWindow.isVisible` 返回 false 时，立即移除该 id 并触发 `onVisibilityChanged`。
- [x] 2.3 调整 `focusVisibleSubWindow`，在调用 `WindowController.show()` 或 focus method 前先确认 tracked id 仍存在且 visible；对 hidden/closed stale id 执行清理而不是重新显示。

## 3. 设置窗口关闭路径

- [x] 3.1 复核 `DesktopSettingsWindowScreen._closeWindow`、`dispose`、`_closeWindowForExit` 的 `visible=false` 上报顺序，确保应用内关闭和 exit 请求都先清理主窗口 visibility state。
- [x] 3.2 保持 macOS settings sub-window 不注册 `WindowManagerPlugin`，不添加依赖 `window_manager` `mainWindow` 的 close listener。
- [x] 3.3 确认设置窗口热复用语义不变：应用内关闭仍优先 `WindowController.hide()`，重新打开仍可复用或重建可响应窗口。

## 4. 架构与泄漏 guardrails

- [x] 4.1 添加或更新 architecture guardrail，确认本 change 不新增 `application/desktop -> features/*` 或 `core -> state|application|features` imports。
- [x] 4.2 添加或更新 repo scan/guardrail，确认 touched settings window lifecycle code 不包含 subscription、billing、entitlement、receipt、paywall、StoreKit、private overlay 或 paid-feature branching terms。
- [x] 4.3 在实现记录中说明当前 architecture phase 为 `evolve_modularity`，并说明本次通过 application-owned seam 与 guardrail 使 touched area equal or better structured。

## 5. 验证

- [x] 5.1 在 `memos_flutter_app` 运行相关 focused tests，至少覆盖新增 `DesktopWindowManager` visibility tests 和 architecture guardrails。
- [x] 5.2 在 `memos_flutter_app` 运行 `flutter analyze`。
- [ ] 5.3 在可用 macOS 桌面环境手工验证：打开设置窗口后关闭红色按钮或 `Cmd+W`，主窗口模糊状态自动消失且无需点击主页。
