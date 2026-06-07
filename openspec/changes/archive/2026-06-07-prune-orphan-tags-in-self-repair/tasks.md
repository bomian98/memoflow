## 1. Scope Confirmation

- [x] 1.1 Confirm this change implements orphan tag cleanup only through explicit self-repair, not automatic remote sync completion.
- [x] 1.2 Confirm no Memos API compatibility files or `test/data/api` files are changed.
- [x] 1.3 Confirm user-facing copy remains compatible with strict recompute/removal semantics; update localization only if the current copy is insufficient.

## 2. Data-Layer Pruning Seam

- [x] 2.1 Add `TagDbPersistence.pruneOrphanTags()` or equivalent focused persistence helper that deletes leaf tags with no `memo_tags` associations and no children.
- [x] 2.2 Ensure pruning loops until no new orphan leaves remain so hierarchical orphan parents are removed after their children.
- [x] 2.3 Explicitly delete related `tag_aliases` for removed tag ids.
- [x] 2.4 Return a pruned count for tests/logging.

## 3. AppDatabase Facade And Repair Flow

- [x] 3.1 Expose pruning through `AppDatabase` / `AppDatabaseWriteDao` so callers do not import focused DB persistence helpers.
- [x] 3.2 Route `SelfRepairMutationService.repairTagsFromContent()` through the existing tag recompute and then orphan tag prune.
- [x] 3.3 Preserve desktop write-proxy dispatch and data-change notification behavior.
- [x] 3.4 Keep settings UI responsible only for confirmation, busy state, success, and failure rendering.

## 4. Tests

- [x] 4.1 Add a DB/self-repair test proving stale false tags are removed from `memo_tags`, `memos.tags`, search/statistics, and the `tags` table.
- [x] 4.2 Add a hierarchical tag test proving recursive leaf pruning removes child then parent orphan rows.
- [x] 4.3 Add a preservation test proving valid referenced tags remain after repair.
- [x] 4.4 Add or adjust boundary tests if the new pruning facade creates a modularity risk.

## 5. Validation

- [x] 5.1 Run `flutter test test/data/db/memo_tag_persistence_test.dart` from `memos_flutter_app`.
- [x] 5.2 Run relevant architecture guardrails for self-repair/data persistence boundaries.
- [x] 5.3 Run `flutter analyze` from `memos_flutter_app`.
- [ ] 5.4 Run `flutter test` from `memos_flutter_app` before commit or PR.
