## Context

`PasswordLockScreen` 当前直接构造 app bar/scaffold/card rows，并使用 bare `Switch` 和 direct `MemoFlowPalette`。页面行为集中在 `appLockProvider`、password dialog、auto-lock time picker 与 toast/snackbar feedback。本批应只替换 page chrome、sections 和 rows，不移动 app lock state owner。

`VaultSecurityStatusScreen` 是 `webdav_sync_screen.dart` 的 `part`，读取 `desktopSyncFacadeProvider`、`webDavVaultStateRepositoryProvider`、`webDavSettingsProvider`、Vault password/recovery repositories 和 local library state。该页面虽属于 WebDAV parent file，但总控第三批明确包含 Vault security status；本批只能迁移此 part 的安全状态 presentation，不调整 WebDAV sync flow、backup/restore algorithm、provider ownership 或 large `WebDavSyncScreen` 页面。

## Goals / Non-Goals

**Goals:**

- 让 `PasswordLockScreen` 和 `VaultSecurityStatusScreen` 成为 migrated settings files。
- 消除这两个目标文件中的 direct `Scaffold`、direct `MemoFlowPalette`、bare switch、page-local card/action row styling。
- 保留密码锁开启/关闭、设置/修改密码、auto-lock picker、Vault status loading、恢复码查看、清理明文、备份恢复测试、toast/snackbar/dialog 行为。
- 通过 focused tests 和 settings drift guardrail 证明迁移完成。

**Non-Goals:**

- 不迁移完整 `WebDavSyncScreen`。
- 不修改 WebDAV sync、backup、import/export、Vault crypto 或 repositories 的业务逻辑。
- 不改 API files、private hooks、commercial logic、AI settings 或 desktop routing。

## Decisions

### Decision 1: Password lock 使用现有 settings semantic rows

`PasswordLockScreen` SHALL use `SettingsPage` for page chrome, `SettingsToggleRow` for enable app lock, `SettingsNavigationRow` / `SettingsValueRow` for change password and auto-lock time, and `SettingsInfoRow` or section footer for explanatory copy.

Rationale: 该页面的 UI shape 与已迁移 settings pages 相同，不需要 page-local `_Group` / `_ActionRow`。

### Decision 2: Vault status 保留 behavior closures，只迁移 rendering

`VaultSecurityStatusScreen` SHALL keep `_loadStatus`、cleanup reminders、password prompts、recovery code dialog、backup test、local plain cache toggle 和 all provider/service calls in place. Build output should switch to `SettingsPage`、`SettingsSection`、settings rows/actions and theme/settings tokens.

Rationale: Vault security actions 有外部副作用，本批目标是 visual seam migration，不是重新划分 sync/security ownership。

### Decision 3: `webdav_sync_screen.dart` only receives a presentation import if necessary

Because `vault_security_status_screen.dart` is a `part`, imports must live in the parent library. If settings UI seams are needed by the part, adding `settings_ui.dart` import to `webdav_sync_screen.dart` is allowed as a presentation-only dependency. No WebDAV behavior code in the parent file should be edited.

Rationale: 这避免为了 part file 结构引入非法 import，同时控制 large flow scope。

### Decision 4: Drift guardrail shrink is required

完成后 `password_lock_screen.dart` 和 `vault_security_status_screen.dart` SHALL move from `legacyAllowlist` to `migratedFiles` with no broad allowances.

Rationale: 这是防止安全页面回退到 local scaffold/palette/switch styling 的直接 guardrail。

## Risks / Mitigations

- [Risk] 密码锁 enable flow 被 presentation migration 破坏。Mitigation: 保留原 onChanged 顺序和 dialog submit validation，增加 focused widget seam test。
- [Risk] Vault status init load 在 widget test 中需要多个 provider overrides。Mitigation: focused test 只 mock required provider surface；如 provider graph 不稳定，优先保持 runtime migration 与 drift guardrail，记录剩余测试风险。
- [Risk] 误改 WebDAV sync behavior。Mitigation: 不调整 provider/service calls 和 state transitions，父文件只允许 import 级展示依赖。
- [Risk] Shared settings seam 过度扩展。Mitigation: 先复用已有 `SettingsPage`、`SettingsSection`、rows/actions；只有多页面通用缺口才改 `settings_ui.dart`。

## Verification Plan

- `openspec validate migrate-settings-security-pages --strict`
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`
