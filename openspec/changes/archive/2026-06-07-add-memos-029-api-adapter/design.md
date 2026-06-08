## Context

本地参考后端 `memos-0.29.0` 的 `proto/api/v1` 显示，核心 `AuthService`、`MemoService`、`AttachmentService` 路由与 `0.28.0` 保持兼容。`ListMemos.order_by` 仍支持 `pinned`、`create_time`、`update_time`、`name`，不支持 `display_time`；`Memo.display_time` 仍为 reserved。因此当前 `0.28.0` 的 `display_time -> create_time` remap 和 `update_time` 更新语义可以沿用。

`0.29.0` 新增了若干业务端点：

- `GET /api/v1/memos/-/linkMetadata`
- `POST /api/v1/memos/-/linkMetadata:batchGet`
- `POST /api/v1/instance/settings:batchGet`
- `POST /api/v1/instance/settings/notification:testEmail`
- `GET /api/v1/instance/stats`
- `POST /api/v1/ai:transcribe`

这些端点不是让现有登录、同步、memo CRUD 正常工作的前置条件。

## Decisions

### Decision: first layer only

本变更只声明 `0.29.0` 是受支持版本，并把现有核心 API 行为接到 facade/probe/login/session 上。新增业务端点暂不建客户端方法、不建 UI、不建状态流。

原因：

- 降低兼容适配风险。
- 避免在 API version support 中混入产品功能和权限设计。
- 当前用户目标是“第一层适配”，不是接入 AI transcription 或 link preview。

### Decision: add explicit `MemoApi029`

虽然 `MemosServerApiProfiles` 的 `>=0.25` profile 已经覆盖 `0.29.0` 路由形态，仍新增显式 `MemoApi029`。

原因：

- `MemoApiFacade` 使用 enum switch 显式选择版本 facade。
- strict route lock 和 `strictServerVersion` 需要稳定、可测试的版本字符串。
- 登录和 probe 的诊断输出应显示 `0.29.0`，而不是降级到 `0.28.0`。

### Decision: probe order keeps chronological order

`kMemoApiVersionsProbeOrder` 继续按版本从旧到新排列，追加 `v029` 到末尾。现有测试已经把 newest 作为 `.last` 来断言，新增版本应自然成为最新 probe target。

### Decision: preserve modular boundaries

本变更的核心逻辑留在 `data/api`。登录页面只维护手动版本选项；`session_provider.dart` 只负责解析和错误提示。不会从 state/application/core 引入 feature 依赖。

## Alternatives

- **把 `0.29.0` 映射到 `v028` fallback**：代码改动更少，但诊断、probe、手动选择和 strict version 都会混乱，也无法证明 `0.29.0` 是明确支持版本。
- **同时接入 AI transcription/link metadata**：可见功能更多，但会引入权限、设置、UI、错误处理和本地 AI provider 体系的设计问题，不适合第一层适配。

## Risks

- `0.29.0` 后端新增字段可能在当前 model parser 中被忽略，这是可接受的；本次只要求既有能力正常工作。
- Exhaustive switch 增加 `v029` 后可能暴露遗漏路径，需要通过 analyzer 和 API test 收敛。
- `session_provider.dart` 现有错误提示仍写到 `0.27.0`，需要一并更新到 `0.29.0`，否则用户会看到错误支持范围。
