# memos-029-api-adapter Specification

## Purpose
TBD - created by archiving change add-memos-029-api-adapter. Update Purpose after archive.
## Requirements
### Requirement: Memos 0.29.0 is an explicit supported API version
系统 SHALL 将 Memos `0.29.0` 识别为受支持 API 版本，并在登录、会话、facade 和 probe 路径中保留 `0.29.0` 版本身份。

#### Scenario: Version parsing accepts 0.29 releases
- **WHEN** the client parses `0.29`, `0.29.0`, or a patch release such as `0.29.7`
- **THEN** it MUST resolve the value to `MemoApiVersion.v029`
- **AND** normalization MUST return `0.29.0`
- **AND** UI labels and diagnostics MUST display `v0.29.0` or `0.29.0` consistently

#### Scenario: Facade uses explicit 0.29 adapter
- **WHEN** an authenticated, unauthenticated, session-authenticated, or password-sign-in API is created for `MemoApiVersion.v029`
- **THEN** the client MUST construct an API instance with effective server version `0.29.0`
- **AND** it MUST use strict modern route locking for Memos `0.29.0`

#### Scenario: Login supports manual 0.29 selection
- **WHEN** a user manually selects a server version during login
- **THEN** `0.29.0` MUST be available as a supported option
- **AND** unsupported-version error messages MUST NOT claim that support ends before `0.29.0`

### Requirement: Memos 0.29.0 reuses existing modern core API behavior
系统 SHALL 对 Memos `0.29.0` 复用现有 `0.25+` modern REST route profile，用于 auth、memo CRUD、attachments、memo attachments、personal access token、notifications 和 existing update-time behavior。

#### Scenario: Core routes match modern v1 shape
- **WHEN** the app talks to a `0.29.0` server for current user, memo list/create/update/delete, attachment upload/get/delete, or memo attachment binding/listing
- **THEN** it MUST use the same route shape as `0.28.0`
- **AND** route compatibility tests MUST cover `0.29.0`

#### Scenario: Display-time ordering remains remapped
- **WHEN** the app requests `display_time` ordering against a `0.29.0` server
- **THEN** the request MUST NOT send unsupported `display_time`
- **AND** it MUST use the same remap behavior as `0.28.0`

#### Scenario: Update-time field behavior remains supported
- **WHEN** the app sends a memo update with an intended `update_time` to a `0.29.0` server
- **THEN** the modern `UpdateMemo` request MUST include `update_time` in `updateMask`
- **AND** the request body MUST include the corresponding `updateTime`

### Requirement: New 0.29 business endpoints are out of scope
系统 SHALL NOT require first-layer `0.29.0` support to implement new product features for `linkMetadata`, `InstanceStats`, notification email testing, batch instance settings, or AI transcription.

#### Scenario: Core adapter does not expose new 0.29 feature surface
- **WHEN** the `0.29.0` adapter is added
- **THEN** it MAY ignore unknown response fields from new backend capabilities
- **AND** it MUST NOT add UI entry points, state flows, or product behavior for the new `0.29.0` endpoints in this change

### Requirement: API version support preserves modular boundaries
系统 MUST keep API version compatibility logic in existing owners and MUST NOT introduce new reverse dependencies while adding `0.29.0` support.

#### Scenario: Version logic remains in data/session owners
- **WHEN** `0.29.0` support is added
- **THEN** facade and route logic MUST remain under `memos_flutter_app/lib/data/api`
- **AND** session parsing and login option wiring MUST remain in their existing state/UI owners
- **AND** the implementation MUST NOT add new `state -> features`, `application -> features`, or `core -> state|application|features` imports

