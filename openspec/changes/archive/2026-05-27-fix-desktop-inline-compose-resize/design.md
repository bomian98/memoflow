## Context

当前桌面首页 inline compose resize 有三层条件：

```text
home/root registry
  └─ passes enableDesktopResizableHomeInlineCompose

MemosListScreen
  └─ _enableResizableHomeInlineCompose
       ├─ !kIsWeb
       ├─ defaultTargetPlatform == TargetPlatform.windows
       └─ widget.enableDesktopResizableHomeInlineCompose

render path
  └─ DesktopResizablePanelShell wraps MemosListInlineComposeCard
```

问题在于入口和平台能力混在一起：`HomeRootDestination.memos` 会传 flag，但 `buildDrawerDestinationScreen(AppDrawerDestination.memos)`、desktop utility return 等路径可能创建未启用 flag 的 `MemosListScreen`。用户确认 Windows 也无法拉伸，因此需要同时验证“入口是否启用”和“真实拖拽 hit test 是否生效”。

Dependency direction before:

```text
features/home -> features/memos
features/memos -> application/desktop/DesktopResizablePanelShell
features/memos -> state/settings/devicePreferences
```

Dependency direction after should remain the same or better:

```text
features/home -> features/memos through existing destination builders
features/memos -> same-layer/helper capability decision
features/memos -> application/desktop/DesktopResizablePanelShell
features/memos -> state/settings/devicePreferences
```

本变更不新增 `state -> features`、`application -> features` 或 `core -> features` 依赖。若需要抽取 helper，应优先放在 `features/memos` same-layer 或已有 `core/platform_layout.dart` 这类 feature-agnostic seam，但不能让 lower layer import feature UI。

## Goals / Non-Goals

**Goals:**

- Windows desktop home inline compose 在所有主 memos 入口下都能 resize。
- 将 resize 能力决策集中化，避免未来新增入口漏传 `enableDesktopResizableHomeInlineCompose`。
- 真实拖拽测试覆盖用户行为，不只断言 handle 存在或直接调用 callback。
- 保持草稿、附件、linked memos、位置、tag autocomplete、preview pane、keyboard shortcut 和 layout persistence 行为不变。
- 让 touched area 在 `evolve_modularity` 下更好：减少入口级平台分支，并增加入口一致性 guardrail/test。

**Non-Goals:**

- 不重写 memo list、editor、preview pane 或 desktop shell。
- 不改变 inline compose 的业务提交逻辑、草稿模型、附件处理或 API 行为。
- 不启用或适配 Linux desktop resize；Linux 当前保持 unsupported/fallback。
- 不新增商业化、订阅、entitlement、paywall、StoreKit 或私有 overlay 逻辑。
- 不把 `DesktopResizablePanelShell` 变成通用可配置布局框架，除非真实 hit test bug 需要局部修复。

## Decisions

### 1. 用 capability helper 统一 resize 启用条件

Decision: 将 `MemosListScreen` 的 resize 判断收敛为一个语义 helper，例如 `supportsDesktopHomeInlineComposeResize(platform, presentation, navigationHost)` 或同等实现。入口仍可表达 presentation/context，但最终能力判断集中在一个 seam。

Rationale: 当前 flag 是入口传递和平台判断混合的结果，容易出现“初始首页可用、抽屉回首页不可用”的分叉。集中 helper 能让 tests 覆盖一个规则，并让 future drawer/root destinations 复用同一判断。

Alternatives considered:

- 只在 `buildDrawerDestinationScreen` 补传 flag：修复当前明显入口，但继续保留分散判断，后续仍容易回归。
- 直接默认所有 `MemosListScreen(enableCompose: true)` 都启用 resize：会影响 mobile/tablet/embeddedBottomNav，不够克制。

### 2. 先修 Windows，支持平台显式表达；Linux 保持 disabled

Decision: Supported desktop scope 至少包括 Windows。若 macOS 当前桌面 home shell 使用同一 inline compose 路径且测试可覆盖，可以通过同一 capability 开启；Linux 不在本批启用。

Rationale: 用户确认 Windows 已回归；Linux 当前未适配，不能把“desktop”粗暴等同三端全开。显式平台支持比 `TargetPlatform.windows` scattered branch 更清楚。

Alternatives considered:

- 继续 Windows-only：能修用户当前 bug，但和正在推进的 platform experience model 方向冲突。
- 三个 desktop 平台全部启用：Linux 未适配，风险超过本 change 的验证范围。

### 3. 用真实拖拽测试补足 guardrail

Decision: 除现有 `DesktopResizablePanelShell` 单元测试外，增加 `MemosListScreen` 或 home route 级 widget test：从当前主路径渲染页面，拖动 `desktop-resizable-panel-*` handle，断言面板尺寸或持久化 layout 发生变化。

Rationale: 现有测试主要证明 shell 可以 resize，或证明 handle 存在。它不能证明主界面中的 handle 没有被父级 scroll/layout/modal surface 遮挡，也不能证明不同入口都启用了 capability。

Alternatives considered:

- 只补 source/constructor test：更快但无法捕获实际 hit test 回归。
- 只保留手动 smoke：不符合该回归的可自动化性质。

### 4. 保持 persistence owner 不变

Decision: `homeInlineComposePanelLayout` 继续由 `devicePreferencesProvider` / `DevicePreferences` 持久化，本变更不迁移数据 owner。

Rationale: 这是已有用户设备级布局偏好，触及模型迁移会扩大范围；修复入口和 hit testing 不需要改变持久化结构。

## Risks / Trade-offs

- [Risk] 修复入口后仍无法拖动，真实原因是 hit zone 被 `CustomScrollView`、desktop shell 或 overlay 截获。→ Mitigation: 增加真实拖拽测试；如失败，再局部调整 `DesktopResizablePanelShell` hit testing 或父级 clip/padding。
- [Risk] macOS 一并启用后视觉或 window chrome 行为不一致。→ Mitigation: 先用 capability 明确 supported platforms；macOS 如果纳入实现，必须有 focused test 或手动 smoke 项。
- [Risk] 入口统一 helper 位置不当引入反向依赖。→ Mitigation: helper 放在 `features/memos` same-layer 或 feature-agnostic lower seam，禁止 `core/application/state` import `features/memos`。
- [Risk] 布局恢复测试不稳定。→ Mitigation: 优先断言 shell rect/persisted preference 的行为，避免依赖过细的像素位置。

## Migration Plan

1. 先补 failing/coverage tests：入口一致性、真实拖拽、persisted layout。
2. 收敛 resize capability 判断，并修复 drawer/root/utility memos 入口。
3. 仅在需要时局部修复 `DesktopResizablePanelShell` 或父级布局 hit testing。
4. 运行 focused tests 和 architecture guardrails。
5. 若需要 rollback，保留原 feature flag 默认 false 路径，回退 helper 的 supported platform 判定即可。

## Open Questions

- macOS 是否在本 change 中正式启用 resize，还是先只保证 Windows 并保留 macOS 后续任务？建议实现时以测试可覆盖为准；Linux 明确不启用。
- 如果真实拖拽测试在 Flutter widget test 中受限，是否补充 source guardrail + `DesktopResizablePanelShell` integration test 组合覆盖？
