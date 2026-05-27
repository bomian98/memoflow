## Context

当前代码里已经有两套正确方向的“半成品”：

```text
platform/widgets
  ├─ PlatformPage
  ├─ PlatformListSection
  ├─ PlatformListSectionRow
  ├─ PlatformSwitch
  ├─ PlatformPrimaryAction
  └─ picker/dialog/popover seams

features/settings
  ├─ some screens use PlatformPage / PlatformListSectionRow
  ├─ many screens still use Scaffold / MemoFlowPalette / custom cards
  └─ repeated private widgets: _ToggleCard, _CardGroup, _SectionCard, ...
```

`PreferencesSettingsScreen` 接近目标：页面主体用 `PlatformPage`，分组和行用 `PlatformListSectionRow`，开关用 `PlatformSwitch`。

`ComponentsSettingsScreen` 仍然手写：`Scaffold`、透明 `AppBar`、背景渐变、`_ToggleCard`、`Switch`、卡片颜色和阴影。它和 `PreferencesSettingsScreen` 同属于设置系统，但 UI 语义不在同一层表达。

## Core Diagnosis

问题不是“某个颜色错了”，而是 screen 层承担了太多设计系统职责。

当前实际形态：

```text
Settings screen
  ├─ decides page chrome
  ├─ decides background/card/text colors
  ├─ decides rounded card geometry
  ├─ decides switch implementation
  ├─ decides button variant style
  └─ decides platform branching
```

目标形态：

```text
Settings screen
  └─ expresses semantic intent
       ├─ SettingsPage
       ├─ SettingsSection
       ├─ SettingsNavigationRow
       ├─ SettingsValueRow
       ├─ SettingsToggleRow / SettingsToggleCard
       ├─ SettingsPrimaryAction
       ├─ SettingsSecondaryAction
       └─ SettingsDangerAction

Settings UI seam
  ├─ maps settings semantics to platform widgets
  ├─ owns settings spacing/surface/action tokens
  └─ delegates platform differences to platform widgets/model

Platform UI system
  ├─ resolves platform experience
  ├─ owns iPhone/iPad/macOS/Windows/Linux/web behavior differences
  └─ stays free of higher-layer imports
```

## Platform Experience Model

`TargetPlatform` is not enough. The app needs a normalized platform experience model that separates several axes:

```text
Runtime platform
  android | iOS | macOS | windows | linux | web

Form factor
  phone | tablet | desktop | web

Input model
  touch | pointerKeyboard | hybrid

Window model
  mobileScene | tabletScene | desktopWindow | browserViewport

Visual family
  materialMobile | cupertinoMobile | appleDesktop | windowsDesktop | linuxDesktop | webMaterial

Navigation model
  bottomTabs | drawer | splitView | sidebarRail | desktopSidebar | desktopOverlay
```

This allows the code to ask better questions:

```text
Bad:
  isApplePlatform() => iOS and macOS mixed
  isDesktopPlatform() => macOS and Windows mixed even when chrome differs

Better:
  experience.formFactor == desktop
  experience.visualFamily == appleDesktop
  experience.inputModel == pointerKeyboard
  experience.navigationModel == desktopSidebar
```

The model does not require rewriting every caller at once. It should first exist as a seam, then migrated callers can move from scattered helpers to semantic queries.

## Settings UI Seam

首批 seam 应该足够小，先覆盖两个样板页面：

```text
SettingsPage
  wraps PlatformPage / desktop shell context where needed
  owns background, safe area, max width, title chrome

SettingsSection
  wraps PlatformListSection
  owns section padding, dividers, grouped/inset behavior

SettingsNavigationRow
  row with title, subtitle/value, leading icon, trailing chevron

SettingsToggleRow
  row with title, optional description, PlatformSwitch

SettingsToggleCard (optional)
  only if card-like toggle semantics are intentionally different from rows
  must still use shared tokens and PlatformSwitch

SettingsAction
  semantic variants:
    primary | secondary | tonal | text | danger
```

Key principle:

```text
Feature screens SHALL NOT call a shared color.
Feature screens SHALL call a semantic component or variant.
```

Example target expression:

```dart
SettingsToggleRow(
  title: Text(context.t.strings.legacy.msg_image_compression),
  description: Text(context.t.strings.legacy.msg_image_compression_desc),
  value: imageCompressionSettings.enabled,
  onChanged: ...
)
```

The row decides whether that becomes:

- iPhone/iPad: Cupertino grouped list row with Cupertino switch.
- Android: Material list row / adaptive switch.
- macOS: dense grouped settings row, Apple desktop spacing.
- Windows/Linux: dense desktop row, desktop bounded content.

## Dependency Direction

Allowed direction:

```text
features/settings/*
  └─ imports settings UI seam and platform widgets

settings UI seam
  └─ imports platform widgets, platform experience model, core theme tokens

platform/*
  └─ imports Flutter/core only; no features/state/application/data
```

If the settings UI seam lives under `features/settings/shared` or `features/settings/widgets`, it may be settings-feature-owned and can import i18n or feature-local helpers only when necessary. If it lives under `platform/widgets`, it must stay feature-agnostic. Initial implementation should prefer a settings-owned seam for settings semantics, backed by feature-agnostic platform widgets.

## Migration Strategy

### Phase 1: Inventory and seam shape

Inventory `features/settings/*.dart` for:

- direct `Scaffold`
- direct `MemoFlowPalette`
- direct `Switch` / `Switch.adaptive`
- `styleFrom`
- private `_ToggleCard`, `_CardGroup`, `_SectionCard`
- repeated background gradient/appbar construction
- platform branches or `Platform.is*`

Use the inventory to define seam API names and legacy allowlist.

### Phase 2: Pilot pages

Migrate only:

- `PreferencesSettingsScreen`
- `ComponentsSettingsScreen`

Acceptance:

- both pages render through the same `SettingsPage` and `SettingsSection` concepts
- both use the same toggle row/card semantic component
- both use `PlatformSwitch` or settings toggle seam
- both preserve existing setting behavior and navigation
- mobile and desktop differences come from platform/settings seam, not screen-local style

### Phase 3: Guardrails

Add focused guardrails:

- `platform/` still cannot import higher layers
- settings UI seam does not import forbidden commercial terms
- new/changed settings pages cannot introduce bare `Switch`, `_ToggleCard`, page-local `styleFrom`, or direct `MemoFlowPalette` unless allowlisted
- platform experience model owns new platform classification helpers

### Phase 4: Follow-up migration

Create a tracked list for remaining settings pages. Future batches should shrink allowlists rather than broad rewrite everything here.

## UI Acceptance Heuristics

本变更后续的视觉讨论已经形成一组明确决策，记录在 `settings-visual-decisions.md`。后续设置页整改应优先遵守该文件中的平台分类、设置页骨架、颜色语义、行组件和轻量强调规则。

For the pilot pages, compare these surfaces on phone and desktop:

```text
Settings -> Preferences
Settings -> Components
```

They should feel like sibling pages:

- same background family
- same title/chrome behavior
- same content width rules on desktop
- same grouped section behavior
- same switch geometry and active color semantics
- same row density and text hierarchy
- no page-local card style that visually contradicts the other page

They should still be platform-appropriate:

- iPhone: touch-friendly, Apple grouped settings behavior where applicable
- iPad: grouped/split-friendly, not merely stretched phone UI
- macOS: dense desktop settings, native-feeling chrome/window semantics
- Windows/Linux: desktop density and bounded content, no Apple-only assumptions

## Testing and Guardrails

Focused tests should cover:

- `PreferencesSettingsScreen` and `ComponentsSettingsScreen` both use expected platform list/control types under iOS/macOS/Windows as appropriate.
- desktop content is bounded and dense.
- iPhone uses grouped list/touch control behavior.
- toggles preserve provider interactions.
- settings UI guardrail allowlist is present and shrinking-friendly.
- platform experience classification returns distinct values for iPhone, iPad, macOS, Windows, Linux, Android, and web-like contexts.

## Open Questions

- `SettingsToggleCard` 是否应该长期存在，还是所有设置开关都应统一为 grouped rows？首批可以先保留 semantic toggle card，但它必须共享 tokens。
- settings UI seam 放在 `features/settings/widgets` 还是 `platform/widgets`？建议首批放在 settings-owned seam，避免让 feature-specific semantics 污染 `platform/`。
- 平台体验 model 是否替代现有 `PlatformTarget`，还是先作为 `PlatformExperience` 与 `PlatformTarget` 并存？建议先并存，迁移完成后再清理旧 helper。
