## Context

`NavigationModeScreen` 和 `BottomNavigationModeSettingsScreen` 已有 focused tests 覆盖 bottom bar selection、detail settings separation、slot picker、unavailable destination filtering 和 duplicate destination disabling。`CustomizeHomeShortcutsScreen` 也在 settings focused tests 中覆盖三个 slot、本地模式候选和 signed-in 候选。`CustomizeDrawerScreen` 被 collections / drawer 相关测试直接渲染。

这些页面目前的问题是视觉实现分散：重复 `Scaffold` / `AppBar` / dark gradient / rounded card / divider / `MemoFlowPalette` styling，且 `CustomizeDrawerScreen` 直接使用 bare `Switch`。本批迁移目标是把可共享的 page chrome、section grouping、toggle rows 和 navigation rows 交给 `settings_ui.dart`，而不是重写 provider 或 destination resolver 行为。

## Decisions

- `NavigationModeScreen` 使用 `SettingsSelectableItemRow` 表达模式选择，并使用独立 `SettingsNavigationRow` 表达 bottom settings 入口；保留 `bottomSelectKey` 和 `bottomSettingsKey`。
- `BottomNavigationModeSettingsScreen` 使用 `SettingsPage` 和 `SettingsSection` 包住 slot rows；preview 可保留 page-local presentation helper，但必须使用 `settingsPageTokens` / theme colors 而非 direct `MemoFlowPalette`。
- Picker dialogs 保留 `AlertDialog` 和 `RadioListTile` 结构以降低行为风险，但颜色改为 theme/settings tokens。
- `CustomizeDrawerScreen` 的 `_ToggleRow` 删除，直接使用 `SettingsToggleRow`。
- `CustomizeHomeShortcutsScreen` 的 slot rows 迁移为 `SettingsNavigationRow`；dialog candidate list 保留现有 `RadioListTile` 行为。
- 本批不修改 `settings_ui.dart`，除非现有 seam 明显无法表达当前 page chrome/row 行为。

## Risks

- `NavigationModeScreen.bottomSettingsKey` 在 classic mode 下应保持可找到但不可打开 settings detail，避免测试和用户交互语义回归。
- Bottom navigation slot tests 通过 visible text / row tap 打开 dialog；迁移到 semantic row 后需要保证 tap target 仍可用。
- `CustomizeHomeShortcutsScreen` 的 resolved actions 依赖 account availability；迁移只替换 row chrome，不改变 resolver 或 selected/disabled 计算。

## Alternatives

- 迁移 AI / desktop settings：仍被 active changes 的 pending smoke tasks 阻塞，按总控规则继续 deferred。
- 迁移 import/export、migration 或 shortcut editor：这些是行为密集页面，适合 dedicated batch，不应与 navigation customization 混在同一批。
