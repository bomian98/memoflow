## Why

`ExportMemosScreen` 与 `import_export_shared_widgets.dart` 仍在 settings UI drift guardrail 的 `legacyAllowlist` 中，并持有 direct `Scaffold`、page-local `AppBar`、direct `MemoFlowPalette`、page-local export button 和 bare `Switch`。导出页面的 zip/markdown/attachment 处理逻辑已经存在，本 change 只收敛 UI surface drift，让剩余 legacy list 更准确。

本批继续按 `coordinate-settings-ui-migration-batches` 的门禁推进，不修改导出数据、数据库查询、附件读取、路径、平台插件、API 或 private/commercial 边界。

## What Changes

- 将 `ExportMemosScreen` root 迁移到 `SettingsPage`，用 settings semantic sections/rows/actions 承载 date range、include archived、export format、export action、last export path 和说明文字。
- 将 `ImportExportSelectRow` / `ImportExportToggleRow` 的使用替换为 `SettingsValueRow` / `SettingsToggleRow` 或等价 settings seam。
- 如果 `import_export_shared_widgets.dart` 迁移后无 runtime 引用，则在确认无 imports、path dependency、workflow/build/tool/runtime path references 后删除；否则让它进入 migrated tracking 并移除 direct palette/bare switch。
- 保留 `_export`、range picker、include archived state、haptics、toast/snackbar/dialog、clipboard copy path、zip/markdown/sidecar/attachment export behavior 和 labels。
- 更新 `settings_ui_drift_guardrail_test.dart`，将 `export_memos_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`，并处理 `import_export_shared_widgets.dart` 的移除或 migrated tracking。
- 增加 focused widget tests，覆盖 export settings seam、date/export format rows、include archived toggle、export button disabled/loading surface 或 copy path UI 的稳定行为。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: export memos settings surface SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/export_memos_screen.dart`
  - `memos_flutter_app/lib/features/settings/import_export_shared_widgets.dart` only if retained; otherwise it may be deleted after reference verification
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - focused settings widget test under `memos_flutter_app/test/features/settings/`
- Public/private/API boundary:
  - 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
  - 不修改 export data format、database queries、attachment fetching、SAF/path provider/gallery/platform plugin behavior、WebDAV、local network migration、AI settings、desktop routing/window、shortcut editor、memo toolbar、private hooks 或 commercial logic。
- Architecture phase: `evolve_modularity`。本 change 触碰 settings feature UI 和 guardrail，必须缩小 drift allowlist，不新增 `state -> features`、`application -> features` 或 `core -> higher-layer` dependency。
