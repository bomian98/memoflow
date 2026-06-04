## Context

当前普通 memo 编辑会先在本地 `memos` 表写入 `update_time = now`，并将 `update_memo` 放入 outbox。remote sync 随后调用 modern `UpdateMemo`。问题在于请求形态缺少 `update_time`，服务端不会刷新 `updated_ts`，后续 remote sync 会把服务端旧 `updateTime` 覆盖回本地。

share-inline 图片上传路径也有同类问题。上传完成后，客户端会把 memo 内容中的本地图片 URL 改写为远端或源图片 URL，并刷新本地 `update_time`。当该路径不 enqueue 单独的 `update_memo` 操作，而是直接调用 `_syncCurrentLocalMemoContent` 时，也必须把本地刚写入的 `updateTime` 转发给服务端。

首页排序还有第二个一致性问题：当前 provider/DB 查询先按 `pinned DESC, COALESCE(display_time, create_time) DESC` 取前 `pageSize` 条，UI 再对已加载候选集应用 `MemosListSortOption`。这会让“更新时间排序”在分页边界上不完整，即使服务端和本地 `update_time` 已正确更新，旧创建时间 memo 仍可能无法进入第一页候选集。

本变更处于 `evolve_modularity` 阶段。触碰路径主要是 `data/api`、`state/memos` 和 `data/db`，不应新增 `state -> features`、`application -> features` 或 `core -> state|application|features` 依赖。排序规则需要从 feature controller 的 UI-only 逻辑下沉到 query/model/persistence seam，以改善 touched area 的职责归属。

## Goals / Non-Goals

**Goals:**

- 普通编辑、pin/archive、附件关系/位置等本地会刷新 `update_time` 的变更，在 remote sync 时也刷新服务端 `update_time`。
- share-inline 上传完成后直接同步当前 memo 内容时，发送与本地 rewrite 相同的 `updateTime`。
- `preserveUpdateTime` 语义保持不变：任务 checkbox 快捷勾选等操作不应刷新 `update_time`。
- “更新时间，升序/降序”排序必须影响查询层候选集，避免 UI 只重排当前 page 的局限。
- API compatibility tests 覆盖 modern `UpdateMemo` 携带 `update_time` 的请求形态。
- 列表排序测试覆盖旧创建时间但新 `update_time` 的 memo 能在更新时间排序下进入首页结果。
- 保持模块边界：API 字段构建在 `data/api`，outbox 和 sync intent 在 `state/memos`，DB ordering 在 `data/db` persistence。

**Non-Goals:**

- 不新增完整的 Memos `0.29` facade，除非实现过程中发现 `update_time` 行为必须依赖显式版本枚举。
- 不改变 `display_time` 本地语义，也不重新设计 memo 时间调整功能。
- 不改变任务 checkbox 快捷勾选不刷新更新时间的产品语义。
- 不全面处理非首页搜索、AI search、shortcut search 的所有排序展示体验，除非它们复用同一 query seam 时自然受益。

## Decisions

### Decision 1: 在 outbox payload 中显式表达 `update_time`

普通编辑保存时，`MemoMutationService.saveEditedMemo` 已经拥有同一个 `now`，应把该时间写入 `update_memo` payload。`_handleUpdateMemo` 解析 payload 后传给 `api.updateMemo(updateTime: ...)`。

选择 outbox payload 而不是在 `_handleUpdateMemo` 中重新 `DateTime.now()` 的原因是：本地 DB 已经用保存时刻作为 optimistic `update_time`，remote 请求应与本地 optimistic state 对齐，避免慢同步时更新时间漂移。

### Decision 2: 直接同步 share-inline 重写内容时转发本地 `updateTime`

`_replaceShareInlineMemoContent` 会调用 `_rewriteLocalMemo` 改写本地 memo 内容并写入新的 `update_time`。当上传完成路径随后调用 `_syncCurrentLocalMemoContent`，该函数会从 DB 重新读取 memo，因此可以直接使用 `memo.updateTime` 作为 modern `UpdateMemo` 的 `updateTime`。

这个路径不应再生成新的时间，也不应只依赖 content PATCH 的服务端默认行为。它必须把本地 rewrite 的时间同步到服务端，防止下一轮 remote sync 用旧 server `updateTime` 回滚本地排序状态。

### Decision 3: 扩展 `MemosApi.updateMemo` 支持 `DateTime? updateTime`

modern `_updateMemoModern` 增加 `updateTime` 入参。当入参非空且当前 server flavor 支持时，追加 `updateMask.add('update_time')` 并写入 `data['updateTime']`。这与 Memos proto 字段 `update_time` / JSON `updateTime` 匹配，并适用于当前支持的 `0.24` 到 `0.28` modern API。

legacy `0.21` route 不需要支持该字段；`0.22` grpc-web 路径如不具备编码支持，则保持不发送。测试需要锁定各版本行为，避免破坏既有兼容路线。

### Decision 4: 保留 `preserveUpdateTime` 作为唯一“不刷新更新时间”语义开关

所有调用 `updateMemoContent(... preserveUpdateTime: true)` 的路径不得在 outbox payload 中加入 `update_time`。现有已知路径是 memo card 的任务 checkbox 快捷勾选，该操作还设置 `triggerSync: false`，不能因为本次修复被提升到最新更新时间。

普通编辑器保存、内容编辑、pin/archive、位置、关系/附件变更等只要本地写入了新的 `updateTimeSec`，remote payload 或直接 sync 请求也应携带同一个时间。

### Decision 5: 将首页排序选项传入 query/persistence 层

当前 `MemosListHeaderController.compareMemos` 只服务 UI 排序。实现应引入稳定的查询层排序模型，例如在 state/data 层定义不依赖 feature 的 `MemoSortOrder`，并由 feature controller 映射用户选择。

`MemoSearchDbPersistence.listRows` 根据该排序生成 `ORDER BY`：

- create desc: `pinned DESC, COALESCE(display_time, create_time) DESC`
- create asc: `pinned DESC, COALESCE(display_time, create_time) ASC`
- update desc: `pinned DESC, update_time DESC, COALESCE(display_time, create_time) DESC`
- update asc: `pinned DESC, update_time ASC, COALESCE(display_time, create_time) DESC`

这样候选集由 DB 按目标排序取数，UI 的 `applyHomeSort` 可保留为防御性稳定排序，或逐步收敛为仅用于非 DB-backed source。

### Decision 6: 用测试作为边界 guardrail

本变更会接触已耦合的 memo state/data 路径。模块化改进不通过大重构完成，而通过两个 guardrail 完成：

- API compatibility 和 remote sync regression tests 防止 future changes 再次丢失 `update_time`。
- DB/list query tests 防止 UI-only sort 再次造成分页候选集错误。

依赖方向保持：

- `features/memos` 将用户选择映射为 state/data 层可理解的排序输入。
- `state/memos` 不 import `features`。
- `data/db` 只接收纯数据排序枚举或参数。

## Risks / Trade-offs

- [Risk] 某些旧 modern server 对 `update_time` 更新不兼容。Mitigation: 用版本能力判断或测试确认，仅对支持 `update_time` 的 modern versions 发送；遇到明确不支持的 legacy path 保持旧行为。
- [Risk] 客户端可写 `update_time` 可能使本地时间成为服务端更新时间来源。Mitigation: 仅在客户端已经本地写 `update_time = now` 的操作中发送同一时间，不引入用户任意设置更新时间的 UI。
- [Risk] 查询层排序引入 query key 变化后可能影响分页重置。Mitigation: 将 sort order 纳入 query key/list signature，排序切换时重置 page size 与 animated list 状态。
- [Risk] pinned memo 的排序语义不清。Mitigation: 保持现有行为，pinned 始终在非 pinned 之前，同组内按选定时间排序。
- [Risk] remote sync 成功后仍有短暂 UI 闪动。Mitigation: 先保证 server updateTime 正确，后续 full sync 的 upsert 不应再回退更新时间；必要时测试本地保存后和 sync 后两个阶段。
