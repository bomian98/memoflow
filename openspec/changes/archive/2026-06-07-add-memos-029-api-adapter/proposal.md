## Why

Memos `0.29.0` 后端已经放入本地参考项目。当前 Flutter 客户端的公开 API 版本模型只到 `0.28.0`，即使 `0.29.0` 的核心 auth、memo CRUD、attachment 路由与 `0.28.0` 基本兼容，客户端仍会因为版本解析、登录自动探测、手动版本选项、`MemoApiFacade` switch 和 probe 覆盖缺失而无法稳定使用 `0.29.0` 实例。

本变更先做第一层适配：让 `0.29.0` 可被识别、登录、探测和同步，复用已有 modern API 路由契约。`0.29.0` 新增的 `linkMetadata`、`InstanceStats`、notification email test、AI transcription 等业务能力不纳入本次实现，避免把“版本可用性”和“新功能接入”混在一起。

项目当前处于 `evolve_modularity` 阶段。本变更主要触碰 `data/api`、登录版本选择和会话版本解析路径，不应引入新的 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖。

## What Changes

- 增加 `MemoApiVersion.v029`，让 `0.29`、`0.29.0`、`0.29.x` 解析为 `0.29.0`。
- 增加 `MemoApi029` facade adapter，使用 strict route lock 和 `strictServerVersion: 0.29.0`，复用 `0.25+` modern REST 路由 profile。
- 扩展 `MemoApiFacade`、`MemoApiProbeService`、登录手动版本选项和会话错误提示，使 `0.29.0` 成为受支持版本。
- 补充 API compatibility tests，覆盖 `0.29.0` 的版本解析、route shape、auth、memo CRUD、attachment、`update_time` 和 `display_time` remap 行为。
- 明确本次不接入 `0.29.0` 新增业务端点；后续需要产品入口时另起 OpenSpec change。

## Capabilities

### New Capabilities

- `memos-029-api-adapter`: 约束客户端对 Memos `0.29.0` 的第一层兼容适配，包括版本识别、API facade、probe、登录和核心路由兼容性。

### Modified Capabilities

<!-- No existing spec-level capability is directly modified. -->

## Impact

- Affected code:
  - `memos_flutter_app/lib/data/api/memo_api_version.dart`
  - `memos_flutter_app/lib/data/api/memo_api_029.dart`
  - `memos_flutter_app/lib/data/api/memo_api_facade.dart`
  - `memos_flutter_app/lib/data/api/memo_api_probe.dart`
  - `memos_flutter_app/lib/features/auth/login_screen.dart`
  - `memos_flutter_app/lib/state/system/session_provider.dart`
  - Exhaustive `MemoApiVersion` switches in state/import paths and tests
- Affected tests:
  - `memos_flutter_app/test/data/api/...`
- API impact: `0.29.0` becomes a supported API version for existing auth, memo, attachment and update-time behavior.
- Architecture impact: active phase is `evolve_modularity`; this change should preserve existing ownership boundaries and add route/version guard coverage without moving shared domain logic into UI files.
