## Context

桌面端设置窗口和其他 full-page 二级页面需要统一“返回 + 页面标题”的 App 内导航语义，同时保留 macOS 原生红色关闭按钮关闭窗口、Windows/Linux 原生窗口控制不被内容覆盖的语义。

本 change 已经把代码整改、自动化测试、架构 guardrail 和 OpenSpec 校验作为主体工作完成。真实桌面窗口中的人工 smoke 项已转入 `verify-desktop-platform-smoke-gaps`，原 change 不声称这些平台操作已人工验证。

当前架构阶段为 `evolve_modularity`。该 change 触碰桌面页面 chrome、设置页和分享 full-page route 的耦合区域，因此实现方向必须通过共享页面/导航 chrome seam 收敛，而不是在各页面局部手写 titlebar offset、App-owned `X` 或 close-vs-back 规则。

## Goals / Non-Goals

**Goals:**

- 为 full-page 二级页面提供一致的 App-level back + title 语义。
- 让 macOS 原生 close 继续关闭窗口，而不是承担页面返回职责。
- 让桌面二级页面标题和返回控件避开 macOS traffic lights 与 Windows/Linux 原生窗口控制区。
- 让设置窗口关闭后重新打开回到设置首页。
- 将 settings 与 share 的二级页面规则沉淀到共享 seam 和 guardrail。

**Non-Goals:**

- 不重绘系统原生窗口按钮。
- 不把 dialog、popover、tooltip、bottom sheet 纳入 full-page 二级页面规则。
- 不在本 change 中完成真实设备/桌面运行时人工 smoke；这些已转入 `verify-desktop-platform-smoke-gaps`。

## Decisions

1. 二级页面用共享 App-level chrome 表达返回和标题。

   备选方案是每个页面继续自行组合标题、返回按钮和关闭按钮。这个方案会重复引入 macOS traffic-light 避让和 close/back 混淆，因此不采用。

2. 原生窗口关闭语义不复用为页面返回语义。

   macOS 红色关闭按钮关闭当前窗口；页面返回由 App 内 back affordance 表达。这样符合桌面平台预期，也避免设置窗口嵌套路由和窗口生命周期互相污染。

3. 设置窗口重新打开回到 root。

   设置窗口属于 root-scoped utility surface。关闭后恢复到上次二级页容易造成 stale route 和用户困惑，因此重新打开默认显示设置首页。

4. 分享 full-page route 遵循同一套二级页面规则。

   分享流程里的 full-page 子页面如果不是根任务面，也应使用 Back + Page Title。真正取消整个分享任务应使用明确的 task action，而不是 macOS 右上角 App-owned `X`。

5. 人工 smoke 单独追踪。

   自动化覆盖和 guardrail 不能完全替代真实 macOS/Windows 窗口按钮、traffic lights、截图和手感验证。相关人工项统一转入 `verify-desktop-platform-smoke-gaps`，不阻塞本 change 表达代码整改已经完成。

## Risks / Trade-offs

- [Risk] 某些 legacy 页面暂未迁移，仍可能局部手写 chrome。  
  Mitigation: 保留并收缩 allowlist，后续迁移页面时通过 guardrail 防止新增漂移。

- [Risk] 真实 macOS 窗口中仍可能出现 traffic-light 重叠。  
  Mitigation: 该风险已显式转入 `verify-desktop-platform-smoke-gaps` 的人工 smoke 任务。

- [Risk] share full-page route 的取消语义与返回语义混淆。  
  Mitigation: spec 要求 task cancellation 使用明确 action，非根二级页使用 App-level back。
