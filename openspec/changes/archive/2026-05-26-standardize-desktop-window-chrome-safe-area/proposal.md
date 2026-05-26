## Why

已有 `desktop-window-chrome-safe-area` 规则覆盖了主窗口和设置窗口，但新的分享 task window 截图显示：只要一个新桌面窗口没有显式接入统一 chrome safe-area，标题和 macOS traffic lights 仍会重叠。这个问题不应靠每个页面各自调 padding，而应把所有会绘制到原生窗口控件区域附近的桌面窗口纳入统一规则。

当前架构阶段为 `evolve_modularity`。本 change 触及 desktop shell、feature root composition 和既有 `core/desktop/window_chrome_safe_area.dart` seam；需要保持 touched area equal or better structured，避免在 feature pages 中继续扩散 macOS traffic-light magic padding。

## What Changes

- 扩展既有 `desktop-window-chrome-safe-area` capability：从“主窗口/设置窗口避让”提升为“所有 desktop task window / shell root 顶层内容必须通过共享 chrome safe-area 规则避让原生窗口控件”。
- 定义 share task window、未来 task windows、以及已存在桌面窗口 root 的统一接入方式：页面只表达标题、返回、actions 和 body 语义，不自行计算 macOS traffic-light 或 Windows/Linux caption-control 避让。
- 分享 task window 作为本轮新暴露问题的第一消费方接入共享规则；设置窗口当前体验不作为重新设计范围，但后续若触碰设置窗口 chrome，应复用同一规则。
- 增加 guardrail / focused tests，防止新 desktop task window root 绕过共享 safe-area seam。
- 不改变 native close 语义；safe-area 只负责布局避让，不引入 App-owned close/cancel UI。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `desktop-window-chrome-safe-area`: 补充 desktop task window / shell root 必须消费共享 safe-area 的要求，并约束 feature pages 不得用页面级 magic padding 避让原生窗口控件。

## Impact

- 预计影响 `memos_flutter_app/lib/core/desktop/window_chrome_safe_area.dart` 或其上层 shared shell/widget seam。
- 预计影响分享 task window root，例如 `lib/features/share/desktop_share_task_window_app.dart`、`lib/features/share/share_clip_screen.dart` 或等价 wrapper。
- 可能新增/调整 architecture 或 widget tests，例如 `test/core/desktop/...`、`test/architecture/...`、`test/features/share/...`。
- 不触碰 API 请求/响应、route adapters、version compatibility logic 或 `memos_flutter_app/lib/data/api` / `memos_flutter_app/test/data/api`。
- 不引入 StoreKit、subscription、entitlement、receipt、paywall、billing 或其他商业化逻辑。
