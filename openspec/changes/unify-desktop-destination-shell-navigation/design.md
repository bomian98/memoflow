## Context

项目已经存在三类相关抽象：

```text
platform/widgets/PlatformPage
  └─ 统一普通页面 AppBar / Cupertino / desktop top-level title policy

features/home/desktop/DesktopShellHost
  ├─ WindowsDesktopPageShell
  └─ AppleMacosPageShell

core/desktop/desktop_titlebar_navigation_policy.dart
  └─ 统一 titlebar navigation context / top-level chrome omission policy
```

但顶层 drawer destination 页面仍大量保留页面级分支：

```text
Feature Page
  ├─ Windows: DesktopShellHost(...)
  └─ macOS/other: Scaffold + AppBar + resolveDesktopTopLevelLeading(...)
```

已识别的顶层页面包括 `DailyReviewScreen`、`ExploreScreen`、`AiSummaryScreen`、`TagsScreen`、`ResourcesScreen`、`NotificationsScreen`、`AboutScreen`、`CollectionsScreen`、`RecycleBinScreen` 和 `SettingsScreen`。这些页面有相同的结构需求：drawer/rail/sidebar、title、actions、body、secondary pane 或 modal surface，但每个页面各自判断 Windows/macOS，导致 back/close/title 行为容易漂移。

Dependency direction before:

```text
features/<page>
  ├─ imports DesktopShellHost
  ├─ imports AppDrawer / AppDrawerDestination
  ├─ imports desktop_titlebar_navigation_policy through DesktopShellHost export
  └─ owns Windows-vs-macOS shell branch locally

features/home/desktop
  ├─ DesktopShellHost routes to concrete platform shell
  └─ platform shell owns chrome layout details
```

Dependency direction after:

```text
features/<page>
  ├─ imports unified desktop destination shell seam
  ├─ provides semantic destination/title/actions/body slots
  └─ does not locally branch Windows-vs-macOS for top-level shell

features/home/desktop
  ├─ owns platform shell routing
  ├─ owns titlebar navigation-context policy application
  └─ owns Windows command bar and macOS toolbar/chrome behavior
```

本 change 不应新增 `state -> features`、`application -> features` 或 `core -> features` 依赖。由于 shell seam 位于 `features/home/desktop`，它可以组合 `AppDrawer` 和 drawer destination 语义，但不应让 lower layer 依赖 feature UI。

## Goals / Non-Goals

**Goals:**

- 让顶层 desktop drawer destination 页面通过同一个 shell seam 表达页面意图。
- 消除已识别顶层页面中的 `isWindowsDesktop ? DesktopShellHost(...) : Scaffold(...)` shell 分叉。
- 让 top-level title、back/close 控件、sidebar/rail/overlay、Windows command bar、macOS traffic-light safe-area 和 expanded-sidebar title suppression 由 desktop shell layer 统一处理。
- 保留 Windows 和 macOS 平台外观差异，不把两者强行渲染成同一种 UI。
- 增加 guardrail，防止后续 AI 或人工修改重新在 feature page 中引入页面级 desktop shell 分支。
- 在 `evolve_modularity` 下改善 touched area：减少页面级平台分支，并让 guardrail 覆盖这一类漂移。

**Non-Goals:**

- 不清理项目现有 `state -> features`、`application -> features`、`core -> higher layer` allowlist。
- 不重构 `app.dart`、`main.dart` 或 multi-window startup。
- 不改变业务数据、API、DB schema、同步、mutation service 或 provider owner。
- 不迁移所有 settings 子页面 UI；`SettingsScreen` 只处理顶层 desktop shell 组合。
- 不改变 native macOS close dispatch 的现有语义；本 change 只确保页面不自行实现该语义。
- 不启用 Linux 作为完整桌面 shell 目标；Linux 保持现有 fallback 或明确例外。

## Decisions

### 1. 用 destination shell seam 表达顶层页面意图

Decision: 在 `features/home/desktop` 内新增或增强统一 seam，例如 `DesktopDestinationShell` 或等价的 `DesktopShellHost` API。调用侧传入 `selectedDestination`、`title`、`actions`、`body`、`secondaryPane`、`modalSurface` 和 `navigationContext`，不再自己选择 Windows/macOS shell 树。

Rationale: 当前 `DesktopShellHost` 已经能路由 Windows/macOS，但页面仍然绕过它为 macOS 写单独 Scaffold。新的 seam 应把“顶层 drawer destination”变成一等语义，让页面不需要知道当前是 Windows command bar 还是 macOS toolbar。

Alternatives considered:

- 只把每个页面的 Windows 分支补齐：能快速统一视觉，但仍保留重复平台分支，未来继续漂移。
- 只增强 `PlatformPage`：`PlatformPage` 更适合普通 route/page scaffold，不天然拥有 drawer destination、secondary pane、Windows command bar 和 macOS desktop shell 的组合语义。
- 直接让所有页面无条件调用现有 `DesktopShellHost`：可行但 API 仍偏底层，页面仍需要自己构造 navigation builder 和 title/action slots，guardrail 难以表达 top-level destination 语义。

### 2. Shell layer 决定 titlebar leading/title/dismissal 行为

Decision: 顶层页面不得把 back/close control 包进 `leadingTitle`。如果页面需要表达 dismissal 行为，应通过 shell seam 的语义字段表达，例如 `topLevelDismissalIntent` 或 settings 顶层 close intent；shell 根据 platform、navigation mode、navigation context 决定是否渲染。

Rationale: `leadingTitle` 混入按钮后，shell 无法判断这是顶层 destination title、secondary task dismissal，还是普通 command。随机漫步 Windows/macOS 不一致就是这种混合造成的。

Alternatives considered:

- 继续允许页面传任意 `leadingTitle` widget：灵活但无法 guardrail，AI 后续容易继续把平台控制塞进 title。
- 禁止所有顶层 close/back：过于粗暴，`SettingsScreen` 等页面可能仍有明确 close 语义，需要通过 seam 表达。

### 3. 分批迁移顶层 destination，避免扩大到所有 desktop pages

Decision: 本 change 只迁移顶层 drawer destination。secondary task、editor、detail、dialog/subwindow、settings 子页继续使用现有 `PlatformPage` 或专用 shell，除非它们直接参与这次顶层 shell 组合。

Rationale: 顶层 destination 的问题同质且可 guardrail；secondary pages 涉及 route pop、unsaved changes、native close dispatch，混在一起会扩大风险。

Alternatives considered:

- 一次迁移所有桌面页面：范围过大，容易碰到 editor、detail、settings 子页的业务/保存语义。
- 只迁移随机漫步：会修当前现象，但不能解决同类页面继续漂移。

### 4. Guardrail 从“禁止具体 shell import”升级到“禁止页面级 shell 分叉”

Decision: 扩展 `desktop_shell_boundary_guardrail_test.dart` 或新增 guardrail，扫描已迁移顶层 destination 页面，禁止 `? DesktopShellHost(`、`isWindowsDesktop ? DesktopShellHost` 这类模式，并禁止 `DesktopShellHost.leadingTitle` 附近手写 back/close `IconButton`。

Rationale: 现有 guardrail 能防止 feature page 直接 import concrete platform shell，但挡不住页面在 `DesktopShellHost` 和 `Scaffold` 之间分叉。需要把刚发现的问题变成自动化约束。

Alternatives considered:

- 只靠 widget tests：能覆盖已知页面，但无法阻止新页面复制旧分支。
- 只靠 review/AGENTS 文档：对 AI 编程不够强，容易局部修复。

## Risks / Trade-offs

- [Risk] 统一 shell seam 过大，变成新的万能组件。→ Mitigation: 只覆盖顶层 drawer destination 的已知 slots；secondary task 和独立子窗口保持现有路径。
- [Risk] `SettingsScreen` 顶层 close 语义与普通 destination 不同。→ Mitigation: 把 close 表达为显式 semantic intent，并用 focused test 覆盖 Windows/macOS 行为。
- [Risk] macOS expanded-sidebar title suppression 与 Windows title visibility 差异被误抹平。→ Mitigation: shell seam 统一输入，不统一视觉；平台 shell 继续拥有具体渲染。
- [Risk] 页面迁移导致 drawer navigation、tag navigation、notifications entry 行为变化。→ Mitigation: 每个迁移页面保留原 navigation callbacks，并增加至少一个跨平台 shell widget test。
- [Risk] Guardrail pattern 误伤普通 secondary pages。→ Mitigation: guardrail 先限定已迁移顶层 destination allowlist，后续逐步扩大。

## Migration Plan

1. 设计并添加 unified desktop destination shell seam，保持现有 `DesktopShellHost` concrete routing。
2. 先迁移一个低风险页面（建议 `DailyReviewScreen` 或 `AboutScreen`）验证 API 和测试形态。
3. 分批迁移 review/AI/explore、resource/tags/about、collections/recycle/settings。
4. 添加或收紧 guardrail，禁止已迁移页面再出现页面级 Windows/macOS shell 分叉。
5. 跑 focused widget tests、desktop shell guardrails、platform UI guardrails 和 `flutter analyze`。

Rollback strategy: 如果某个页面迁移出现行为回归，可保留 unified seam 并暂时只回退该页面的调用，但 guardrail 中应记录临时例外和后续任务，避免永久分叉。

## Open Questions

- 统一 seam 应命名为新的 `DesktopDestinationShell`，还是增强 `DesktopShellHost` 并保留单一公开入口？
- `SettingsScreen` 顶层 close 是否属于 top-level dismissal intent，还是应保留在 settings-specific shell wrapper 中？
- macOS rail 模式和 expanded sidebar 模式是否都需要在首批 widget tests 中覆盖，还是先覆盖 expanded sidebar title suppression 与 Windows command bar？
