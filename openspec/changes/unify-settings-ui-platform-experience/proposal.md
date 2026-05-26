## Why

当前设置页和平台适配已经出现可感知的不一致：`PreferencesSettingsScreen` 已经较多使用 `PlatformPage`、`PlatformListSectionRow`、`PlatformSwitch` 等语义化平台组件，而 `ComponentsSettingsScreen` 仍然手写 `Scaffold`、卡片、颜色、圆角和 `Switch`。类似分歧在设置模块内还有多处，导致同一个设置系统中不同页面的按钮颜色、开关样式、行高、卡片形态和桌面/移动表现漂移。

同时，平台分类仍然混乱：代码中同时存在 `Apple = iOS + macOS`、`Desktop = Windows + macOS + Linux`、`iPad = iOS + 宽度阈值`、以及 Windows/macOS 专用 shell 分支。Apple 平台在操作上像手机、UI 上又混入桌面/Windows 逻辑，根因不是单个页面样式问题，而是缺少统一的 platform experience model。

本变更在 `evolve_modularity` 阶段进行，触及 `settings`、`platform`、`core/platform_layout.dart`、桌面 shell 相关热点。变更必须让 touched area equal or better structured：抽取设置 UI 语义 seam，减少页面级样式和平台分支，并增加 guardrail 防止继续漂移。

## What Changes

- 建立统一的设置页 UI 语义层，使设置页面表达 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow`、`SettingsToggleRow`、`SettingsAction` 等意图，而不是直接决定颜色、圆角、按钮背景和平台控件。
- 以 `PreferencesSettingsScreen` 和 `ComponentsSettingsScreen` 作为首批样板页面，统一它们的页面 chrome、分组、行、开关、背景、桌面宽度、Apple grouped list 和桌面 dense row 行为。
- 定义统一的 platform experience classification，把运行平台、form factor、input model、window model、visual family、navigation model 拆开表达，避免只靠 `TargetPlatform` 或 `isApplePlatform` 做混合判断。
- 收敛设置页中对 `MemoFlowPalette`、`styleFrom`、裸 `Switch`、手写 `_ToggleCard`、直接 `Scaffold` 的使用路径；新增或收紧架构 guardrail，采用 allowlist 逐步迁移。
- 更新 `platform-adaptive-ui-system` 规格，明确 settings UI seam 和 platform experience model 的要求。

## Non-Goals

- 不一次性迁移所有设置页。
- 不重写整个 App shell、memo list、editor 或所有 Apple 平台 UI。
- 不新增商业化、订阅、付费、StoreKit、entitlement、paywall 或私有 overlay 逻辑。
- 不改变现有设置项的业务语义、持久化模型、provider owner 或 API 行为。
- 不在 `platform/` seam 中引入 `features/*`、`state/*`、`application/*`、`data/*` 反向依赖。

## Initial Scope

首批实现聚焦：

- `memos_flutter_app/lib/features/settings/preferences_settings_screen.dart`
- `memos_flutter_app/lib/features/settings/components_settings_screen.dart`
- 新增或调整设置 UI seam 所需的 shared UI 文件
- `memos_flutter_app/lib/platform/platform_target.dart` 或等价平台体验分类 seam
- `memos_flutter_app/test/architecture/...` 与相关 focused widget tests

## Modularity Impact

Active architecture phase: `evolve_modularity`.

Touched checklist items:

- `4.` no reused shared domain logic hidden inside screen or widget files: 设置页 reusable UI 逻辑从 screen-local widgets 抽到稳定 UI seam。
- `6.` feature-to-feature collaboration prefers boundary, registry, or provider seams: 设置页统一通过 shared settings UI seam 和 platform widgets，而不是页面直接复制 UI。
- `8.` architecture guardrail tests protect highest-risk dependency directions: 增加 settings UI 和 platform experience drift guardrail。
- `10.` every change touching a coupled area leaves that area equal or better structured: 首批页面迁移必须减少样式分散和平台分支。

Planned touched-area improvement:

- 抽取或建立 settings UI semantic seam。
- 明确 platform experience model，减少散落平台判断。
- 对设置页裸样式和裸平台控件增加 guardrail/allowlist。

## Risks

- 首批 seam 设计过窄，后续页面迁移时不断破坏抽象。Mitigation：任务中要求先盘点设置页常见 row/action/surface 模式，并只抽取真实重复语义。
- 一次收紧 guardrail 导致大量遗留页面失败。Mitigation：使用 allowlist 起步，每迁移一个页面收缩 allowlist。
- 平台分类命名过度抽象，实际页面仍绕过它。Mitigation：用 `PreferencesSettingsScreen`、`ComponentsSettingsScreen`、桌面设置窗口和 Apple shell 作为验证样例。
- 视觉统一被误解成所有平台完全一样。Mitigation：统一的是语义和 token 调用，不是强迫 iPhone、iPad、macOS、Windows 使用同一布局。
