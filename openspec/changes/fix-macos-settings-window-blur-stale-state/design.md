## Context

主窗口模糊由 `DesktopWindowManager.shouldBlurMainWindow` 根据 `_desktopVisibleSubWindowIds` 决定，`app.dart` 只根据这个 application-owned 状态渲染 `BackdropFilter`。设置子窗口在应用内关闭路径会执行 `_notifyMainWindowVisibility(false)`，但 macOS 原生关闭按钮或 `Cmd+W` 可能只让 `desktop_multi_window` 从 native 窗口集合移除子窗口，不一定有机会让 Dart 子窗口向主窗口同步 `visible=false`。

现有 `macos-settings-window` spec 已要求 macOS 设置子窗口不能调用依赖 `window_manager` `mainWindow` 的 API，也不能把 `WindowManagerPlugin` 注册进设置子窗口 Flutter engine。因此本 change 不能通过在 macOS 设置子窗口里加 `WindowListener` 来解决问题。

当前 dependency direction：

- `app.dart` 作为 composition root 持有 `DesktopWindowManager` 并渲染模糊层。
- `application/desktop/desktop_window_manager.dart` 管理桌面子窗口可见性，不应新增 `features/*` imports。
- `features/settings/desktop_settings_window_app.dart` 可以通过现有 `desktop_multi_window` method channel 回报设置窗口状态。

变更后 dependency direction 保持不变：窗口可见性 reconciliation 仍由 `application/desktop` 持有，设置 UI 只发送语义状态或响应查询，不把 feature widget 构造或商业逻辑下沉到 lower layers。

## Goals / Non-Goals

**Goals:**

- macOS 设置窗口通过应用内关闭、原生红色关闭按钮、`Cmd+W` 或隐藏路径消失后，主窗口模糊状态 SHALL 自动解除，不要求用户先点击主页。
- 主窗口 SHALL 能清理 stale sub-window id：当 `getAllSubWindowIds()` 不再包含该 id，或子窗口 visibility query 返回 false 时，应更新 `_desktopVisibleSubWindowIds` 并触发重建。
- 点击模糊层聚焦子窗口前 SHALL 先避免复活已隐藏/已关闭的 stale 设置窗口。
- 保持设置窗口热复用：应用内关闭仍优先 `hide()`，不把所有关闭路径都改成 destroy。
- 增加 focused tests/guardrail，覆盖 stale id 清理和不新增 reverse dependency。

**Non-Goals:**

- 不重构整个 desktop multi-window runtime。
- 不修改 API compatibility、request/response model、route adapter 或 `memos_flutter_app/lib/data/api`。
- 不引入新的 native dependency、commercial/private overlay、StoreKit、subscription、billing、entitlement 或 paywall 逻辑。
- 不改变 Windows quick input、share task window 或主窗口 close-to-menu-bar 策略，除非共享 helper 的测试需要同步调整。

## Decisions

1. 在 `DesktopWindowManager` 内增加或收紧可见性 reconciliation。

   `DesktopWindowManager` 已经拥有 `_desktopVisibleSubWindowIds`、`scheduleVisibilitySync()`、`_syncDesktopSubWindowVisibility()` 和 `focusVisibleSubWindow()`，是最合适的状态 owner。实现应让可见性同步不只依赖下一次 Flutter build：当主窗口进入 blur 状态或收到可见子窗口上报时，安排短延迟/可取消的 sync，直到确认集合为空或状态稳定。

   Alternative considered: 在 `app.dart` 里直接轮询子窗口状态。拒绝，因为 `app.dart` 会继续变胖，不利于 checklist item 5。

2. 不在 macOS 设置子窗口注册 `window_manager` 或使用 `WindowListener`。

   现有 spec 明确禁止 macOS 设置子窗口调用依赖 `window_manager` `mainWindow` 的 API。native close 后 `desktop_multi_window` 会从 sub-window id 集合移除窗口，主窗口 reconciliation 可以通过 `DesktopMultiWindow.getAllSubWindowIds()` 发现 stale id。

   Alternative considered: 给 macOS settings sub-window 添加 `window_manager` close listener。拒绝，因为会违反现有 `macos-settings-window` plugin boundary。

3. 让 focus path 先校验再聚焦。

   `focusVisibleSubWindow()` 当前用于点击模糊层时把焦点还给子窗口。实现应先查询 tracked id 是否仍存在且 visible，再调用 `WindowController.show()` 或 settings focus method。若 id 不存在或已不可见，应移除 tracking 并触发主窗口重建，避免用户点击主页时把隐藏设置窗口重新 show 出来。

   Alternative considered: 保留现有点击时 focus-first 行为，只依赖后台 sync 清理。拒绝，因为这个路径会让 stale hidden window 有机会被重新显示。

4. 用 focused tests 覆盖状态机，而不是依赖手工验证。

   优先为 `DesktopWindowManager` 增加可测试 seam 或测试辅助入口，验证：`visible=true` 后 blur 为 true；sync 发现 id 缺失或 query false 后 blur 为 false；focus path 遇到 stale id 会 remove 而不是 claim focused。若现有架构测试能覆盖 imports，则补充 guardrail 断言本 change 不新增 `application -> features` 或 `core -> higher-layer` 依赖。

   Alternative considered: 只做手工 macOS 验证。拒绝，因为该问题由异步生命周期状态引起，回归风险高。

## Risks / Trade-offs

- [Risk] 过于频繁的 visibility sync 可能增加 method channel 调用。→ Mitigation: 使用短延迟、debounce、in-progress queue 和仅在 `_desktopVisibleSubWindowIds` 非空时运行。
- [Risk] 原生关闭后子窗口 engine 已退出，visibility query 可能抛异常或超时。→ Mitigation: 先用 `getAllSubWindowIds()` 过滤；query 失败时只在 health check 确认 responsive 的情况下继续保留。
- [Risk] 更改 focus path 可能影响快速输入窗口或其他子窗口。→ Mitigation: 保留 quick input/settings 的 method-specific focus fallback，但在 focus 前加入共享存在性/visibility 检查，并用测试覆盖 known window type 行为。
- [Risk] macOS 桌面生命周期问题难以在 CI 完整模拟。→ Mitigation: 将核心状态机放在 Dart test 可覆盖的 application seam；macOS 真机验证作为实现后的补充。

## Migration Plan

无需数据迁移。实现可按 application seam 与 settings window UI 两步提交；若出现问题，可回滚到现有手动点击兜底行为。发布后用户无需修改配置。

## Open Questions

- 实现时需确认现有测试基础设施是否已有 `DesktopMultiWindow` fake seam；若没有，应优先为 `DesktopWindowManager` 注入最小的 sub-window client seam，而不是在测试中依赖真实 platform channel。
