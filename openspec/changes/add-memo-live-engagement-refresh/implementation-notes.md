## 2026-06-04 准备项核对

- `add-memos-029-api-adapter` 基线已经在当前工作区可见：`MemoApiVersion` 包含 `v029`，`kMemoApiVersionsProbeOrder` 以 `v029` 结尾，`MemoApiFacade` 覆盖 `unauthenticated`、`authenticated`、`sessionAuthenticated`、`passwordSignIn`，`MemoApi029` 复用 modern strict route 行为。
- 现有 `memoEngagementControllerProvider(MemoEngagementRequest)` 位于 `memos_flutter_app/lib/state/memos/memo_engagement_provider.dart`，已经集中拥有 `listMemoReactions`、`listMemoComments`、`upsertMemoReaction`、`deleteMemoReaction`、`createMemoComment`，并通过 `_reactionsLoadFuture` / `_commentsLoadFuture` 复用 in-flight refresh。
- `MemoEngagementSurface` 在 widget 挂载后调用 controller `load()`，主页 memo card 和 memo detail 只消费该 surface/provider；SSE parsing、长连接生命周期和重连策略不应放进这些 widget。
- 早期活跃 memo uid 方案考虑过由 engagement controller family 注册；实际实现改为由 `memoEngagementLiveRefreshRegistrationProvider(MemoEngagementRequest)` 声明活跃 request，详见下方实现备注。
- API 相关编辑已在用户明确批准后进行。

## 2026-06-04 实现备注

- 用户已明确批准编辑 API 相关代码后，新增 `memos_flutter_app/lib/data/api/memos_live_refresh_api.dart`，包含 `MemosLiveRefreshEvent`、`MemosLiveRefreshSseParser`、`MemosLiveRefreshApi` 和 `0.27+` capability gate。
- 活跃 engagement 注册由 `memoEngagementLiveRefreshRegistrationProvider(MemoEngagementRequest)` 负责；`MemoEngagementSurface` 只 watch 该 provider 来声明当前 request 活跃，不解析 SSE、不创建长连接、不处理重连。
- `MemoEngagementLiveRefreshCoordinator` 在存在活跃 request 且当前账号版本支持 SSE 时订阅 event source；账号切换、退出、token 缺失或 provider dispose 会停止订阅。连接成功后只对 registry 内活跃 request 做补偿刷新。
- `reaction.upserted` / `reaction.deleted` 只触发目标 memo 的 `loadReactions(force: true)`；`memo.comment.created` 只触发 `loadComments(force: true)`；同 memo 短时间事件通过 registry timer 合并，controller 原有 in-flight future 继续防止重复请求。
- 401/404/405/501 在 data API 中作为 live refresh capability unavailable 处理，stream 正常结束且不触发 `onConnected`；coordinator 因未连接成功不会退避重连，等待 session/account 变化后重新创建 event source。
- `toggleLike()` 和 `createComment()` 的乐观更新路径未改动；自己触发的 SSE 只会作为后续服务端权威状态校正。
