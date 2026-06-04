## Context

`ExportMemosScreen` 是 import/export hub 下的导出任务页，负责选择日期范围、是否包含 archived memos、展示固定导出格式、触发现有 `_export` 流程并显示最近导出路径。页面当前的导出核心逻辑较多，包括 DB 查询、markdown/zip/sidecar 生成、附件读取、路径解析、toast/snackbar/dialog 和 clipboard copy。

本批只迁移页面 presentation layer。`import_export_shared_widgets.dart` 目前只被 `ExportMemosScreen` runtime 引用；如果迁移后不再有 runtime/tool/workflow/path 引用，应删除该专用 shared UI 文件，避免为了一个已不用的 wrapper 继续保留 legacy allowlist entry。

当前架构阶段为 `evolve_modularity`。本 change 触碰 settings feature UI 与 guardrail，不改变 `state`、`application`、`core` dependency direction。

## Goals / Non-Goals

**Goals:**

- 将 `ExportMemosScreen` root 迁移到 `SettingsPage`。
- 用 `SettingsSection`、`SettingsValueRow`、`SettingsToggleRow`、`SettingsAction`、`SettingsInfoRow` 或等价 settings seam 承载导出设置和动作。
- 移除 `ExportMemosScreen` 中 direct `Scaffold`、page-local `AppBar`、direct `MemoFlowPalette`、page-local export button visual drift。
- 移除或迁移 `import_export_shared_widgets.dart`，确保它不再保留 legacy drift。
- 更新 focused widget tests 和 `settings_ui_drift_guardrail_test.dart`。

**Non-Goals:**

- 不修改 `_export`、range picker、`_rangeToUtcSec`、memo filename/path sanitization、attachment reading、Dio/SAF/path provider、zip encoding、markdown/sidecar/clip-card export、DB query 或 clipboard copy 语义。
- 不修改 `ImportExportScreen` hub、`ImportSourceScreen`、local network migration、`memoflow_bridge_screen.dart`、`migration/*`、WebDAV、AI settings、desktop routing/window、shortcut editor 或 memo toolbar。
- 不修改 API files、data API tests、request/response models、route adapters、private hooks 或 commercial/private overlay。

## Decisions

### Decision 1: Export page root 使用 `SettingsPage`

`ExportMemosScreen` SHALL replace direct `Scaffold` and local `AppBar` with `SettingsPage(title: Text(...))`。`SettingsPage` already owns background, navigation leading, bounded content and dark-mode background treatment, so export page no longer needs direct `MemoFlowPalette` or desktop titlebar helpers in its build method.

Alternative considered: 给 `export_memos_screen.dart` 添加 drift allowances。拒绝，因为页面 UI can be expressed by existing settings seams with minimal change to behavior.

### Decision 2: Export settings rows 使用 semantic rows

Date range 和 export format SHALL use `SettingsValueRow`。Include archived SHALL use `SettingsToggleRow`。This replaces `ImportExportSelectRow` / `ImportExportToggleRow` and removes the bare `Switch` in the shared file from the runtime path.

Alternative considered: 修改 `import_export_shared_widgets.dart` to wrap settings rows. 暂不采用为默认，因为该 file 只剩 export page 使用；直接在 export page 使用 settings rows 更简单，并可删除 unused wrapper。

### Decision 3: Export action 使用 `SettingsAction`

The export trigger SHALL use `SettingsAction` with the existing `_exporting` disabled/loading state. Haptics and `_export()` invocation remain in the same callback path.

Alternative considered: Keep custom `GestureDetector`/`AnimatedScale` export button. 拒绝，因为 page-local button visual styling is exactly one of the drift patterns this batch removes.

### Decision 4: 删除 shared UI file 前必须验证引用

If `import_export_shared_widgets.dart` is unused after migration, implementation MUST verify all imports/path references across runtime, tests, tools, workflows and OpenSpec artifacts before deleting it. If any runtime use remains, the file MUST be migrated and tracked instead.

Alternative considered: Leave unused file allowlisted. 拒绝，因为 unused legacy files keep the drift signal noisy and may hide future regressions.

## Risks / Trade-offs

- [Risk] Export button visual shape changes from a custom pill to platform/settings primary action. Mitigation: focused tests cover action presence and disabled/loading surface; behavior callback remains unchanged.
- [Risk] Deleting `import_export_shared_widgets.dart` could miss non-import references. Mitigation: run `rg` across repo before deletion and document the result.
- [Risk] Export page has substantial business logic in the same file. Mitigation: edit only imports/build UI and do not touch `_export` helper methods or data models.
