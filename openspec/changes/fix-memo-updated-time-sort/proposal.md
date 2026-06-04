## Why

用户反馈在 Memos `0.28` 以及当前支持的 modern API 版本上，编辑旧 memo 后按“更新时间，最新优先”排序时仍可能不上浮。日志显示客户端同步编辑时只发送 `updateMask=content,visibility,pinned`，没有请求服务端刷新 `update_time`，后续 remote sync 会用服务端旧 `updateTime` 覆盖本地刚写入的更新时间。

同一个问题还出现在 share-inline 图片上传完成后的内容重写路径：本地 memo 内容会被替换为远端图片地址并写入新的 `update_time`，但完成上传后直接调用的 `UpdateMemo` 仍可能不携带该时间。结果是 memo 在本地短暂按新更新时间排序，下一次同步后又回到旧更新时间位置。

本变更需要在 `evolve_modularity` 阶段内修复 memo 更新时间同步语义，并让首页更新时间排序的数据来源与 UI 排序语义保持一致，避免旧 memo 因分页候选集按创建时间截断而无法进入第一页。

## What Changes

- 扩展 memo 更新 API 调用，使普通编辑、附件/属性变更、share-inline 上传完成后的内容重写等会刷新本地 `update_time` 的操作，在 modern `UpdateMemo` 请求中携带 `update_time` 和对应 `updateTime`。
- 保留现有“不刷新更新时间”的语义，例如任务 checkbox 快捷勾选使用 `preserveUpdateTime` 时不得携带 `update_time`。
- 调整 memo 列表查询/排序契约，使“更新时间，升序/降序”由查询层按 `update_time` 取候选，而不是只在 UI 对当前已加载页重排。
- 补充 API compatibility tests、remote sync regression tests 和 memo 列表排序查询测试，覆盖当前 Memos `0.24` 到 `0.28` 的相关更新时间更新行为。
- 在 touched state/data 路径保持现有 owner 边界：API 请求构建留在 `data/api`，outbox payload 解析和 sync 语义留在 `state/memos`，列表排序规则下沉到 query model / DB persistence。

## Capabilities

### New Capabilities

- `memo-updated-time-ordering`: 约束 memo 编辑后的 `update_time` 同步、保留更新时间的例外语义，以及首页更新时间排序必须覆盖分页候选集。

### Modified Capabilities

<!-- No existing spec-level requirement is directly modified. This change touches implementation near `memos-028-compatibility` and `memo-search`, but introduces a narrower behavior contract for updated-time ordering. -->

## Impact

- Affected code:
  - `memos_flutter_app/lib/data/api/memos_api/...`
  - `memos_flutter_app/lib/state/memos/memo_mutation_service.dart`
  - `memos_flutter_app/lib/state/memos/memos_remote_sync_attachments.part.dart`
  - `memos_flutter_app/lib/state/memos/memos_remote_sync_outbox.part.dart`
  - `memos_flutter_app/lib/state/memos/memos_query_models.part.dart`
  - `memos_flutter_app/lib/state/memos/memo_search_coordinator.part.dart`
  - `memos_flutter_app/lib/data/db/memo_search_db_persistence.dart`
  - `memos_flutter_app/lib/features/memos/memos_list_header_controller.dart`
- Affected tests:
  - `memos_flutter_app/test/data/api/...`
  - `memos_flutter_app/test/state/memos/...`
  - focused state/DB/list ordering tests as needed
- API impact: modern Memos `UpdateMemo` requests may include `update_time` in `updateMask` when the client intends the edit to refresh the memo's last-updated time.
- Architecture impact: active phase is `evolve_modularity`. This touches checklist item `7` (write path ownership) and item `8` (guardrails/tests). The change must not add new reverse dependencies and should leave memo mutation/query ownership clearer than before.
