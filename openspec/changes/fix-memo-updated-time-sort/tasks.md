## 1. API update_time Support

- [x] 1.1 Extend `MemosApi.updateMemo` and `_updateMemoModern` with `DateTime? updateTime`.
- [x] 1.2 When `updateTime` is provided for supported modern REST routes, add `update_time` to `updateMask` and `updateTime` to the request body.
- [x] 1.3 Preserve legacy and grpc-web route behavior where `update_time` is unsupported or not encoded.
- [x] 1.4 Update `test/data/api/update_memo_route_compatibility_test.dart` to cover `update_time` request shape for supported modern versions, including `0.28`.
- [x] 1.5 Add or extend API version coverage for `0.29` if the existing facade/version model needs explicit test fixtures for this bug. Current codebase has no `0.29` facade/version by user direction; the `v0_25Plus` support path is ready for the future `0.29` adapter.

## 2. Outbox and Mutation Timestamp Intent

- [x] 2.1 Add a shared update-time payload encoding/decoding approach for `update_memo` payloads in `state/memos` without importing feature-layer code.
- [x] 2.2 Update `MemoMutationService.saveEditedMemo` so existing memo edits enqueue the same `now` used for local `updateTimeSec`.
- [x] 2.3 Update `MemoMutationService.updateMemoContent` so non-`preserveUpdateTime` updates enqueue the refreshed update time.
- [x] 2.4 Audit other `update_memo` enqueue paths that locally write a fresh `updateTimeSec` and carry that same time into the payload.
- [x] 2.5 Ensure `preserveUpdateTime` paths, especially task checkbox toggles, do not enqueue or send `update_time`.
- [x] 2.6 Update `_handleUpdateMemo` to parse `update_time` / `updateTime` and pass it to `api.updateMemo`.

## 3. Query-Level Updated-Time Ordering

- [x] 3.1 Introduce a state/data-layer sort model that represents create/update ascending/descending order without depending on `features/memos`.
- [x] 3.2 Add sort order to `MemosQuery` and relevant provider query keys so changing sort resets pagination predictably.
- [x] 3.3 Map `MemosListSortOption` to the state/data sort model in the feature layer without adding reverse imports.
- [x] 3.4 Extend `MemoSearchDbPersistence.listRows` and related `watchMemos/listMemos` callers to apply query-level `ORDER BY` for updated-time sorting.
- [x] 3.5 Keep pinned grouping behavior stable while applying selected time ordering inside pinned and non-pinned groups.
- [x] 3.6 Decide whether `applyHomeSort` remains as a defensive stable sort for loaded rows or is narrowed to non-DB-backed sources. Kept as a defensive stable sort after DB/query-level ordering.

## 4. Tests and Verification

- [x] 4.1 Add a focused regression test showing an old-create-time memo with new `update_time` appears in the first page for updated-time descending sort.
- [x] 4.2 Add a regression test showing a visible edited memo reorders above older updated memos after local update and after remote sync.
- [x] 4.3 Add a test that `preserveUpdateTime` content updates do not emit `update_time` in remote update payloads.
- [x] 4.4 Run `flutter test test/data/api --reporter expanded` from `memos_flutter_app`.
- [x] 4.5 Run focused new memo ordering tests from `memos_flutter_app`.
- [x] 4.6 Run `flutter analyze` from `memos_flutter_app`.
- [ ] 4.7 Run `flutter test` from `memos_flutter_app` if time allows before PR.

## 5. Modularity Guardrails

- [x] 5.1 Confirm changed files do not introduce new `state -> features`, `application -> features`, or `core -> state|application|features` imports.
- [x] 5.2 Keep API request construction in `data/api`, outbox mutation intent in `state/memos`, and SQL ordering in `data/db`.
- [x] 5.3 Document any unavoidable boundary exception in this change before implementation completion. No new boundary exception was introduced.
