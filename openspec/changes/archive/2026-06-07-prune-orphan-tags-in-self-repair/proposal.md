## Why

Issue #211 暴露了一个本地标签派生数据问题：当远端 memo 删除或移除 tag 后，本地 `tags` 表可能留下没有任何 `memo_tags` 关联的孤儿 tag row，并在 Tags 页面显示为 `count=0`。当前“修复异常标签”只会从 memo 正文重算 `memo_tags`、`memos.tags`、搜索和统计缓存，不会删除这些孤儿 tag registry rows，因此无法完整修复该可见残留。

## What Changes

- 扩展 `Settings -> Help & Diagnostics -> Self Repair -> Repair abnormal tags`，在现有 memo tag recompute 后递归 prune orphan tag rows。
- 新增 data-layer pruning seam，删除没有 `memo_tags` 关联且没有子 tag 的 leaf orphan tags，并清理相关 `tag_aliases`。
- 通过 `AppDatabase` / `AppDatabaseWriteDao` 暴露维护 facade，让 `SelfRepairMutationService` 不直接依赖 focused DB persistence helper。
- 保持 pruning 仅由用户确认的 self-repair action 触发，不作为 remote sync completion 的自动副作用。
- 补充 DB/self-repair 测试，覆盖 stale false tag 删除、层级 orphan leaf-first pruning、有效 tag 保留和边界约束。
- 不删除 memo 内容、账号、偏好、附件、WebDAV backups、sync queues、远端数据或用户文件。

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `self-repair-tools`: 扩展异常标签修复，使它在重算 memo tags 后清理本地孤儿 tag rows。
- `memos-tag-compatibility`: 明确 explicit tag maintenance 后 `tags`、`tag_aliases`、`memo_tags`、`memos.tags`、搜索和统计的持久化一致性。

## Impact

- Affected code: `memos_flutter_app/lib/state/maintenance/self_repair_mutation_service.dart`, `memos_flutter_app/lib/data/db/app_database.dart`, `memos_flutter_app/lib/data/db/app_database_write_dao.dart`, `memos_flutter_app/lib/data/db/tag_db_persistence.dart`, focused tests under `memos_flutter_app/test/data/db`, and architecture guardrails if the seam changes boundary risk.
- Affected data behavior: explicit self-repair may delete local orphan rows from `tags` and `tag_aliases` after memo tags are recomputed from current content.
- API impact: no Memos server API route, request/response model, version adapter, `memos_flutter_app/lib/data/api`, or `memos_flutter_app/test/data/api` changes are intended.
- Architecture phase: `evolve_modularity`.
- Modularity checklist touched: item 4 because shared tag maintenance logic must stay outside screen/widget files; item 7 because pruning write paths need clear data-layer owners; item 8 because guardrail/test coverage should prevent boundary regressions; item 10 because touched data-maintenance code must remain equal or better structured.
