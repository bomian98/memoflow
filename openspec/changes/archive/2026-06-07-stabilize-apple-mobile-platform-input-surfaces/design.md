## Context

`LanguageSelectionScreen` 的 iOS `DropdownButton` 崩溃已经通过 picker seam 方向收敛，但用户在 iPhone 上选择本地模式后又进入 `LocalModeSetupScreen`，新的崩溃发生在设置输入行：

```text
LocalModeSetupScreen
  └── SettingsPage
        └── PlatformPage
              └── iPhone/iPad: CupertinoPageScaffold
                    └── SettingsSection
                          └── PlatformListSection
                                └── CupertinoListSection
                                      └── SettingsInputRow
                                            └── PlatformTextField
                                                  └── TextField  // Material-only
```

`PlatformPage`、`PlatformListSection`、`PlatformListSectionRow` 已经在 Apple mobile 上走 Cupertino chrome/list semantics，但 `PlatformTextField` 仍无条件返回 Material `TextField`。同时 `LocalModeSetupScreen` 的空名称反馈依赖 `ScaffoldMessenger` / `SnackBar`，`show()` 直接使用 `MaterialPageRoute`，这些都让同一个流程的 Apple mobile surface 不完整。

依赖方向当前应保持：

```text
features/onboarding
  └── calls features/settings/LocalModeSetupScreen.show

features/settings
  ├── uses SettingsPage / SettingsInputRow semantic seams
  ├── may use core/top_toast.dart for app feedback
  └── may use platform/platform_route.dart for route presentation

platform/widgets
  └── depends only on Flutter platform primitives and platform_target
```

After 本变更应保持：

```text
features/onboarding
  └── no direct Material/Cupertino input workaround

features/settings
  └── owns settings semantic intent, not raw platform control branching

platform/widgets
  └── owns TextField vs CupertinoTextField behavior
```

本变更触及 `settings` 和 `platform` coupled area，在 `evolve_modularity` 阶段必须留下结构改进：把 Apple mobile input behavior 收敛进 platform/settings seam，并增加 focused guardrail/tests，防止 future page-local workaround。

## Goals / Non-Goals

**Goals:**

- 让 iPhone/iPadOS 在 `PlatformPage` / `CupertinoPageScaffold` 内容中渲染 text input 不再需要隐式 `Material` ancestor。
- 让 `SettingsInputRow` 成为平台安全的设置输入行，避免各设置页分别选择 `TextField` / `CupertinoTextField`。
- 让本地库 setup 的 route、输入、校验反馈和确认结果在 Apple mobile 上形成完整平台化路径。
- 保留 Android、Windows、macOS、Linux 现有 `PlatformTextField` / `SettingsInputRow` 行为，避免扩大视觉和交互变更。
- 增加 iPhone/iPadOS focused widget tests 与 platform dependency guardrail。

**Non-Goals:**

- 不重新设计完整 onboarding flow 或 local library creation data flow。
- 不修改 `LocalLibrary` model、repository、database schema、workspace path、sync/WebDAV 行为。
- 不把整个 app 从 `MaterialApp` 迁移到 `CupertinoApp`。
- 不全面迁移所有设置页或所有裸 `TextField`；本变更聚焦 shared platform/settings seam 和本地库 setup 回归路径。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、price、private overlay 或 commercial branching。

## Decisions

### Decision: `PlatformTextField` 补齐 Apple mobile 分支

实现阶段应让 `PlatformTextField` 在 `PlatformTarget.iPhone` / `PlatformTarget.iPad` 下返回 `CupertinoTextField` 或等效 Apple-safe platform input，并在其他平台继续返回 Material `TextField`。

现有 constructor 接收 `InputDecoration`，这是 Material 语义。第一版可以保留该参数以降低 call-site churn，但应在 platform seam 内做兼容映射：

```text
InputDecoration.hintText       -> CupertinoTextField.placeholder
InputDecoration.hintStyle      -> placeholderStyle
InputDecoration.suffixIcon     -> suffix
InputDecoration.contentPadding -> padding
InputBorder.none               -> decoration: null / transparent decoration
style                          -> style
enabled                        -> enabled
minLines/maxLines              -> minLines/maxLines
obscureText/readOnly/etc.      -> same semantic behavior
```

Alternatives considered:

- 在 `LocalModeSetupScreen` 或 `SettingsInputRow` 外局部包 `Material(type: MaterialType.transparency)`：能压住断言，但保留 Apple page 中 Material-only input 依赖，后续 settings 输入仍会复发。
- 把 `PlatformPage` iOS body 全局包 `Material`：影响范围过大，会掩盖所有 page-local Material-only 控件问题。
- 立即重做 `PlatformTextField` public API，移除 `InputDecoration`：更干净，但会扩大 call-site 修改范围；可作为后续 cleanup。

### Decision: `SettingsInputRow` 继续表达设置语义，平台分歧沉到 seam

`SettingsInputRow` 不应直接成为每个设置页的 iOS workaround。它可以继续组合 `PlatformListSectionRow` + `PlatformTextField`，但应尽量通过平台中立参数传递 intent，例如 `hint`、`fieldLabel`、`suffixIcon`、`enabled`、`minLines/maxLines`、`keyboardType`，让 `PlatformTextField` 负责具体控件映射。

如 Apple mobile 布局需要额外 padding、line height 或 suffix placement，优先在 `SettingsInputRow` 或 `PlatformTextField` seam 内处理，不在 `LocalModeSetupScreen`、`LocationSettingsScreen`、`ShortcutEditorScreen` 等 call sites 分散处理。

Alternatives considered:

- 只修改 `LocalModeSetupScreen` 使用独立 `CupertinoTextField`：修复范围小，但让 shared settings input seam 继续不安全。
- 为 iOS 创建单独 settings page tree：违反现有 platform-adaptive-ui-system 对共享 feature tree 的要求。

### Decision: 本地库 setup 使用平台 route seam

`LocalModeSetupScreen.show()` 应使用已有 `buildPlatformPageRoute`，而不是直接创建 `MaterialPageRoute`。这样 iPhone/iPadOS 的进入、返回手势和 route transition 与 `PlatformPage` chrome 一致。

Alternatives considered:

- 保留 `MaterialPageRoute`：不触发当前断言，但 route semantics 与 Apple mobile page chrome 不一致。
- 在 onboarding 局部 push `CupertinoPageRoute`：会让调用方承担 platform branching；已有 `buildPlatformPageRoute` 更符合 seam ownership。

### Decision: 校验反馈从 Material `SnackBar` 收敛到平台安全反馈

`LocalModeSetupScreen` 空名称校验不应依赖 `ScaffoldMessenger.of(context).showSnackBar`。第一版优先复用项目已有 `showTopToast`，因为它基于 root `Overlay`，已在大量跨页面场景使用，不要求当前 page 是 `Scaffold`。如果未来需要更严格的语义，可以再抽象 `showPlatformFeedback`，但本变更不必为单个校验反馈引入过度 abstraction。

Alternatives considered:

- 使用 `showPlatformAlertDialog`：平台语义清晰，但对空名称这种轻量 validation 过重。
- 保留 `SnackBar` 并依赖 `MaterialApp` 的 root scaffold：当前 `CupertinoPageScaffold` 子树中没有可靠 `ScaffoldMessenger` surface，且体验割裂。
- 新增全局 `showPlatformFeedback`：方向合理，但需要梳理大量 existing `SnackBar` / `showTopToast` call sites；本变更先局部稳定高风险路径。

### Decision: 测试覆盖实际 iOS 本地模式路径

新增或扩展 widget tests 应设置 `debugPlatformTargetOverride = TargetPlatform.iOS` 和 iPhone viewport，覆盖：

```text
LocalModeSetupScreen renders without framework exception
name field accepts editing
empty name shows feedback without framework exception
confirm returns trimmed LocalModeSetupResult
```

此外应保留 Android/desktop existing tests，防止 `PlatformTextField` 兼容映射影响非 Apple 平台。

Alternatives considered:

- 只增加 `PlatformTextField` unit/widget test：能证明 seam，但不能证明 onboarding 本地库 setup 组合路径。
- 只跑现有 onboarding language iPhone tests：不会覆盖 `SettingsInputRow` / local setup 输入行。

### Decision: Guardrail 聚焦 platform dependency direction 与 Apple mobile Material-only regression

如修改 `memos_flutter_app/lib/platform`，应确保不新增 `platform -> features/state/application/data` 依赖。可扩展现有 architecture tests 或新增 focused repo scan。对于 Material-only 控件，guardrail 不应粗暴禁止所有 Material import，因为 platform seam 需要同时支持 Material 和 Cupertino；重点应防止 migrated Apple mobile settings/onboarding paths 在 feature pages 局部添加 workaround 或直接绕过 seam。

Alternatives considered:

- 禁止 `platform/widgets` 引入 `material.dart`：不现实，adaptive wrapper 本身需要 Material fallback。
- 只依赖 manual review：`evolve_modularity` 阶段要求 touched area 留下自动化防线或明确 seam extraction。

## Risks / Trade-offs

- [Risk] `InputDecoration` 到 `CupertinoTextField` 的兼容映射不可能完全等价。→ Mitigation: 第一版只承诺当前 call sites 使用到的 hint、suffix、padding、style、line count、enabled、input formatters 等语义，并用 focused tests 覆盖。
- [Risk] `CupertinoTextField` 的默认 padding/decoration 与现有 settings row 视觉不完全一致。→ Mitigation: 在 `SettingsInputRow` / `PlatformTextField` seam 内调整，不让 feature pages 分散修补。
- [Risk] `showTopToast` 作为 validation feedback 不是完整 platform feedback abstraction。→ Mitigation: 它已是项目现有跨页面反馈入口，且不依赖 `Scaffold`；后续如要统一全部 feedback，可另开 change。
- [Risk] 修改 shared `PlatformTextField` 可能影响 memo compose、share sheet、search 等其他输入场景。→ Mitigation: Apple mobile 分支只影响 iPhone/iPadOS，非 Apple 保持 Material path；实现阶段用 focused smoke tests 覆盖 high-risk call sites。
- [Risk] Architecture guardrail 过宽会阻塞合法 adaptive wrapper。→ Mitigation: guardrail 聚焦 dependency direction 和 migrated feature page workaround，不禁止 platform seam 内部同时 import Material/Cupertino。

## Migration Plan

1. 先补充 focused tests：iPhone `LocalModeSetupScreen` render/edit/validation/confirm，和 `PlatformTextField` iOS/Android render split。
2. 实现 `PlatformTextField` Apple mobile branch 或等效 Apple-safe adapter，保留非 Apple 行为。
3. 调整 `SettingsInputRow` 如需要的 platform-neutral 参数传递和 Apple mobile layout/padding。
4. 调整 `LocalModeSetupScreen.show()` 使用 `buildPlatformPageRoute`，并将空名称 feedback 改为 `showTopToast` 或等效平台安全 feedback。
5. 增加或收紧 architecture guardrail，确认 `platform/` 不引入 higher-layer imports，settings/onboarding touched paths 不新增 page-local Material workaround。
6. 运行 focused tests、architecture tests、`flutter analyze`，变更完成前运行 `flutter test`。

Rollback: 如 Apple mobile input branch 出现不可接受视觉或编辑行为回归，可临时在 `PlatformTextField` seam 内回退为透明 `Material` compatibility fallback，同时保留 tests 标记该 fallback 必须位于 platform seam，而不是 feature page。由于不改数据或 schema，回滚不需要 migration。

## Open Questions

- Apple mobile `PlatformTextField` 是否应第一版直接公开 platform-neutral 参数并逐步替换 `decoration`，还是先兼容 `InputDecoration` 后续清理？设计倾向先兼容，避免扩大变更。
- 空名称 feedback 是否只在 `LocalModeSetupScreen` 使用 `showTopToast`，还是趁机新增轻量 `showPlatformFeedback` seam？设计倾向先用 `showTopToast`，把全局 feedback 统一留给后续 change。
- 是否需要把 `LocalModeSetupScreen.show()` 的 `fullscreenDialog` 或 route settings 暴露出来？当前用例不需要，保持 API 简单。
