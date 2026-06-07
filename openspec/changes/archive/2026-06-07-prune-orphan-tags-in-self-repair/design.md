## Context

`SelfRepairMutationService.repairTagsFromContent()` 当前只代理到 `AppDatabase.rebuildMemoTagsFromContent()`。数据库写入路径会遍历 memo，使用共享 `extractTags()` 和 `MemoTagReconciler` 重新生成 `memo_tags` 与 `memos.tags`，并刷新搜索和统计派生数据。

这个流程不会删除 `tags` 表中不再被任何 memo 引用的 row。`StatsCacheDbPersistence.listTagStatsRows()` 又以 `tags` 为主表 LEFT JOIN `tag_stats_cache` / `memo_tags`，所以孤儿 tag 即使没有统计缓存记录，也会以 `memo_count=0` 出现在 Tags 页面。

依赖方向现状：settings UI 调用 state-layer `SelfRepairMutationService`，service 调用 `AppDatabase` facade，data-layer persistence helper 拥有具体 SQLite 操作。该 change 继续保持这个方向，不让 feature widget 或 state service 直接导入 `TagDbPersistence`。

## Goals / Non-Goals

**Goals:**

- 让用户确认的 abnormal tag cleanup 在重算 memo tags 后清理 orphan tag registry rows。
- 递归删除没有 `memo_tags` 关联且没有子 tag 的 leaf orphan tags，并清理对应 `tag_aliases`。
- 通过 `AppDatabase` / `AppDatabaseWriteDao` 维护 facade 保持 desktop write-proxy dispatch、data-change notification 和数据写入所有权。
- 用 focused tests 覆盖 stale false tag、层级 orphan、有效 tag 保留和边界行为。

**Non-Goals:**

- 不在 remote sync 完成后自动 prune orphan tags。
- 不 cherry-pick Issue #211 的完整 fork branch。
- 不添加或修改 Memos API `0.29` compatibility。
- 不删除 memo 内容、`memos` rows、附件、账号、偏好、local library files、WebDAV backups、sync queues 或远端数据。
- 不添加 commercial/private repair behavior。

## Decisions

1. Orphan pruning 挂在 explicit self-repair action 下，而不是 remote sync。
   - 选择原因：项目支持用户通过 Tag 编辑器创建空 tag；sync 后自动删除全部 0 关联 leaf tag 会误删用户意图。
   - 替代方案：remote sync completion 后自动 prune。该方案更接近 Issue #211 分支，但风险较高，本 change 不采用。

2. SQLite pruning 由 data layer 拥有。
   - `TagDbPersistence` 负责 leaf orphan 查询、删除 `tag_aliases` 和删除 `tags`。
   - `AppDatabaseWriteDao` / `AppDatabase` 负责 transaction/facade/write-proxy/notification。
   - `SelfRepairMutationService` 只编排 facade call，不引入 `state -> data/db focused helper` 的额外耦合。

3. 使用循环 leaf-first pruning。
   - 每轮仅删除没有 memo 关系且没有 child rows 的 tag。
   - 删除子级后，父级若成为 leaf orphan，下一轮再删除。
   - 替代方案：一次性删除所有没有 memo 关系的 tag。该方案可能破坏层级判断，也更难保证 leaf-only 语义。

4. Pruning 顺序放在 `rebuildMemoTagsFromContent()` 之后。
   - 先用当前正文重算，确保仍被正文引用的 tag 被解析、创建或保留。
   - 再 prune 不再 reachable 的 registry rows，避免先删后又重建导致不必要的数据 churn。

## Risks / Trade-offs

- [Risk] 用户确认 self-repair 后，手动创建但未使用的空 tag 可能被删除。→ Mitigation: 保持该行为只在 explicit abnormal tag cleanup 中发生，并沿用/必要时收紧确认文案，说明未出现在正文中的 stored tags 可能被移除。
- [Risk] 层级 tag 删除顺序错误会留下孤儿父级或提前删除父级。→ Mitigation: 仅 prune leaf orphan，并循环到稳定；用层级测试覆盖 child-to-parent 删除。
- [Risk] UI 或 state layer 直接导入 focused DB helper。→ Mitigation: pruning 只通过 `AppDatabase` facade 暴露，并运行 self-repair/data persistence boundary guardrails。
- [Risk] 统计缓存已清理但 `tags` row 残留导致 Tags 页面继续显示 `count=0`。→ Mitigation: 测试直接断言 `listTagStatsRows()` 不再包含 pruned tag。
