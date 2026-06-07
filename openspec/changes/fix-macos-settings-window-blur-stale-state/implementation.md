## Implementation Notes

当前 architecture phase 为 `evolve_modularity`。

本次实现将设置子窗口 visibility reconciliation 保持在 `DesktopWindowManager` 这个 application-owned seam 内：

- `app.dart` 继续只根据 `DesktopWindowManager.shouldBlurMainWindow` 渲染模糊层，不直接轮询或管理 `desktop_multi_window` 状态。
- `application/desktop/desktop_window_manager.dart` 通过可测试 `DesktopSubWindowClient` seam 查询 sub-window ids、visibility、ping/focus/show，不新增 `features/*` imports。
- `features/settings/desktop_settings_window_app.dart` 继续只在 settings window UI composition 内发送 `visible=false` 或响应 visibility query，不把 feature widget 构造或商业逻辑下沉到 lower layers。
- Guardrail 覆盖 `application/desktop -> features/*` 边界与 settings window lifecycle commercial leakage，确保 touched area equal or better structured than before。
