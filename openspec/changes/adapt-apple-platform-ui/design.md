## Context

当前应用 UI 主要围绕 Android / Windows 体验演进：`features/*` 页面大量直接使用 `Scaffold`、`AppBar`、`MaterialPageRoute`、`AlertDialog`、`showModalBottomSheet`、`PopupMenuButton`、`DropdownButton`、`Card` 和 `ListTile`；桌面外壳集中在 `features/home/desktop/`，但命名和实现偏 Windows。Apple 平台已有少量 macOS 运行时、菜单和快捷键能力，但缺少独立的 Apple UI shell 和平台组件适配层。

本 change 的目标是在公共仓建立 Apple 平台 UI 适配能力，同时保持商业化隔离。实现必须复用现有业务页面、state、application services 和 data repositories，不复制 `features_ios/` 页面树，不向 public shell 注入 StoreKit、订阅、买断、价格、receipt 或权益逻辑。

当前架构阶段是 `evolve_modularity`，modularity score 为 `4/10`。本 change 主要触及 checklist item 5、6、8、9、10；若触及 `core`、`home`、`settings`、`memos` 等耦合热点，必须通过集中 UI seam、减少页面内平台判断、增加 guardrail 或收敛平台外壳边界来保证 touched area equal or better structured。

## Goals / Non-Goals

**Goals:**

- 为 iOS、iPadOS 和 macOS 同步建立 Apple 风格 UI 适配路线。
- 新增公共 `platform/` UI seam，用语义组件隔离平台视觉和交互差异。
- 保留现有业务页面主体和状态管理，优先替换高感知 UI 边界。
- iPhone 使用 Apple tab / navigation / alert / action sheet / picker / route transition。
- iPadOS 使用 sidebar / split-view 优先布局，不把 iPhone UI 简单放大。
- macOS 使用独立 desktop shell、toolbar、sidebar、menu / shortcut / window semantics，最终不复用 Windows window controls。
- 以 settings 作为首批试点，再迁移首页、memo list、memo editor、note input 和其他页面。
- 建立可追踪的分批完成标准，直到高感知 Apple UI 区域全部处理完成。
- 增加或维护 guardrail，防止平台 UI seam 造成新的反向依赖或商业逻辑泄漏。

**Non-Goals:**

- 不创建 `features_ios/`、`features_ipad/`、`features_macos/` 完整页面副本。
- 不重写 memo、settings、sync、collections 等业务逻辑。
- 不改 API route、request / response models、version compatibility logic 或 API tests。
- 不引入 StoreKit、subscription、buyout、entitlement、receipt、paywall、App Store Connect 配置或私有发布自动化。
- 不把 Apple 商业状态写入 `AppPreferences`、session/account models、update config、general repositories 或 public shell。
- 不在首批任务中追求所有普通 card / icon / progress indicator 的视觉全量重绘；但必须纳入迁移进度清单。

## Decisions

### Decision 1: 建立 `platform/` UI seam，而不是在 feature 页面散写平台判断

`memos_flutter_app/lib/platform/` 作为公共 UI adapter 层，包含 `platform_target.dart`、`platform_route.dart`、`platform_icons.dart`、`platform_theme.dart`、`widgets/` 和 `shells/`。Feature 页面通过 `PlatformPage`、`PlatformDialog`、`PlatformActionSheet`、`PlatformPicker`、`PlatformGroupedList` 等语义组件表达 UI 意图。

替代方案是在每个页面直接判断 `Platform.isIOS` / `TargetPlatform.macOS`。该方案短期快，但会让平台逻辑散落到 `features/`，并使后续 iPadOS / macOS 分化难以维护，因此不采用。

依赖方向：
- Before: `features/*` 直接依赖 Material / Windows-specific shell，部分 `core` helper 也存在向上依赖风险。
- After: `features/* -> platform/* -> Flutter framework`；`platform/*` MUST NOT import `features/*`、`state/*`、`application/*` 或 `data/*`。

### Decision 2: Apple shell 分为 mobile、tablet、desktop 三类

iPhone 使用 mobile shell：底部 tab 可以保留，但需要 Apple 风格 tab bar、Cupertino-like navigation、iOS route transition 和 edge-back gesture。

iPadOS 使用 tablet shell：优先 sidebar / split-view，复用 destination model，但不复用 Android drawer 视觉。

macOS 使用 desktop shell：使用 sidebar + toolbar + menu / shortcut / window semantics，避免把 `WindowsDesktopPageShell` 的窗口控制作为最终 macOS UI。

替代方案是所有 Apple 平台共享一套 mobile shell。该方案会让 iPad 和 macOS 显得像放大手机应用，不符合用户目标和 App Store 桌面体验要求。

### Decision 3: 首批试点选择 settings，再迁移 memo 主流程

`SettingsScreen`、`PreferencesSettingsScreen` 和部分设置子页是最适合试点的平台组件区域：业务风险低，且 grouped list、picker、dialog、switch、text field 密集，能快速验证 Apple 观感。

随后迁移 `HomeEntryScreen` / shell、`MemosListScreen`、`MemoEditorScreen`、`NoteInputSheet`。这批是最高频主流程，但代码耦合更重，必须在基础 seam 稳定后推进。

### Decision 4: 对话框、菜单和选择器用语义 API 迁移

新增 `PlatformDialog`、`PlatformActionSheet`、`PlatformPicker`，业务代码传 title、message、actions、options、selected value 和 callback，不关心底层是 `CupertinoAlertDialog`、action sheet、popover、dialog 还是 Material fallback。

迁移时优先处理 destructive / confirm / enum selection / date-time selection / card more menu，再处理低感知提示弹窗。

### Decision 5: 进度治理纳入 tasks 和 spec

因为用户要求“全部处理完成，但可分批”，任务必须拆出 inventory、phase checklist 和 completion report。每批迁移完成后更新 `tasks.md` checkbox，并在必要时新增 notes 记录剩余未迁移区域和风险。

### Decision 6: 商业化边界保持现状

Apple UI 适配只处理公共 UI。订阅中心入口、StoreKit、真实权益、商品配置、价格、收据、paywall 和发布自动化仍属于私有 overlay 或后续商业化 change。公共 Apple shell 可以渲染 private bundle 贡献的 settings entries，但不能根据商业状态做 branching。

## Risks / Trade-offs

- [Risk] 全量迁移范围较大，直接一次性改所有页面容易引发回归。  
  Mitigation: 先建立 seam 和 settings 试点，再按首页、memo 主流程、设置子页、其他功能页分批推进。

- [Risk] `platform/` seam 如果导入 feature/state/application，会恶化现有 modularity。  
  Mitigation: 增加 architecture guardrail，要求 `platform/*` 不导入 `features/*`、`state/*`、`application/*`、`data/*`，并把业务 destination 数据通过参数传入。

- [Risk] macOS 和 Windows desktop 共享逻辑边界不清，可能把 Windows shell 继续扩散。  
  Mitigation: `DesktopShellHost` 后续按平台委派，Windows-specific window controls 留在 Windows shell，macOS shell 独立实现 toolbar / sidebar / window semantics。

- [Risk] iPadOS 如果只复用 iPhone tab，会不符合 Apple 平台预期。  
  Mitigation: tablet shell 默认 sidebar / split-view，并仅在窄宽度退化为 mobile-style navigation。

- [Risk] `.adaptive` 控件在复杂页面里行为不完全满足 iOS / macOS 差异。  
  Mitigation: 使用 `PlatformSwitch` 等封装作为唯一入口，内部可以先用 `.adaptive`，后续再按平台增强。

- [Risk] Apple UI 适配可能被误用为商业入口。  
  Mitigation: spec 明确禁止 public shell 中出现 StoreKit、subscription、buyout、entitlement、receipt、price、paywall business branching，并复用/新增 commercial guardrail。

## Migration Plan

1. 创建 `platform/` UI seam 和 platform target / icons / route / page / dialog / picker / action sheet / grouped list 基础组件。
2. 增加 architecture guardrail，保护 `platform/` 依赖方向和 public Apple shell 商业边界。
3. 用 settings 试点验证 `PlatformPage`、`PlatformGroupedList`、`PlatformListTile`、`PlatformSwitch`、`PlatformPicker` 和 `PlatformDialog`。
4. 改造 Apple shell：
   - iPhone: Apple mobile shell。
   - iPadOS: Apple tablet sidebar / split shell。
   - macOS: Apple desktop shell。
5. 迁移 memo 主流程的高感知区域：list header、search、more menu、editor page chrome、note input sheet、confirm dialogs、route transition。
6. 分批迁移 remaining settings、collections、reminders、review、stats、debug 等页面的 high-perception components。
7. 维护迁移进度清单，直到 spec 中列出的 high-perception Apple UI 区域全部完成。
8. 每批运行 `flutter analyze`、相关 widget / architecture tests；最终运行 `flutter test`。

Rollback 策略：保留 Material / Windows fallback path；若某批 Apple 组件出现问题，可让对应 platform adapter 暂时回退到现有 Material implementation，而不回滚业务页面。

## Open Questions

- iPadOS 的 sidebar 默认 destination 集合是否与当前 drawer 完全一致，还是需要精简为更 Apple 风格的信息架构？
- macOS 首版是否需要原生 menu command 覆盖所有主要导航，还是先覆盖 app/menu/window/edit/view 和核心快捷键？
- Apple grouped list 的视觉 token 是否使用当前 `MemoFlowPalette` 派生，还是引入单独的 Apple platform tokens？
- 迁移完成标准是否需要 Playwright / golden screenshot，还是先以 widget tests、architecture tests 和人工平台检查为主？
