## ADDED Requirements

### Requirement: Memo edits refresh remote update_time when local update time changes
The system SHALL send a remote `update_time` update for memo mutations that intentionally refresh the local memo `update_time`.

#### Scenario: Edited memo refreshes server update time
- **WHEN** an existing memo is saved from the normal editor with content, visibility, pinned, location, relation, or attachment changes that update the local `update_time`
- **THEN** the queued `update_memo` sync operation MUST carry the same intended update time
- **AND** the modern `UpdateMemo` request MUST include `update_time` in `updateMask`
- **AND** the request body MUST include the corresponding `updateTime` value

#### Scenario: Remote sync does not roll back edited memo update time
- **WHEN** a memo edit has been synced successfully to a modern Memos server that supports `update_time`
- **THEN** the next remote sync MUST NOT overwrite the local memo with the pre-edit server `updateTime`

#### Scenario: Share-inline upload completion forwards rewritten update time
- **WHEN** a share-inline attachment upload rewrites the local memo content without enqueueing a separate `update_memo` operation
- **THEN** the direct modern `UpdateMemo` request MUST include `update_time` in `updateMask`
- **AND** the request body MUST include the same `updateTime` value that was written to the local memo

#### Scenario: Supported modern versions include update_time
- **WHEN** the app syncs an update to a supported modern Memos server version from `0.24` through `0.28`
- **THEN** the app MUST use the server's `update_time` update field when the mutation is intended to refresh the memo's last-updated time

### Requirement: Preserve-update-time operations do not refresh update_time
The system SHALL preserve existing no-refresh semantics for memo operations that explicitly request `preserveUpdateTime`.

#### Scenario: Task checkbox toggle preserves update time
- **WHEN** a memo task checkbox is toggled through a path that sets `preserveUpdateTime`
- **THEN** the local memo `update_time` MUST remain unchanged
- **AND** any remote update caused by that operation MUST NOT include `update_time` in `updateMask`

#### Scenario: Content update without preserve flag refreshes update time
- **WHEN** memo content is updated through a path that does not set `preserveUpdateTime`
- **THEN** the local memo `update_time` MUST be refreshed
- **AND** the remote update payload MUST carry the refreshed update time

### Requirement: Updated-time sort uses query-level ordering
The system SHALL apply homepage updated-time sort at the query/candidate layer rather than only reordering the currently loaded UI list.

#### Scenario: Old memo with new update time enters first page
- **GIVEN** an old memo has a `create_time` or `display_time` outside the first page when ordered by creation/display time
- **AND** the memo has a newer `update_time` than other normal memos
- **WHEN** the homepage sort option is `updated time desc`
- **THEN** the memo MUST be eligible to appear in the first page of results according to `update_time`

#### Scenario: Visible memo reorders after update
- **GIVEN** a memo is already visible in the homepage list
- **WHEN** that memo is edited and its `update_time` is refreshed
- **THEN** `updated time desc` sorting MUST place it ahead of older updated memos within the same pinned group

#### Scenario: Pinned grouping remains stable
- **WHEN** homepage memos are sorted by updated time
- **THEN** pinned memos MUST remain before non-pinned memos
- **AND** memos within each pinned group MUST be ordered by the selected updated-time direction

### Requirement: Updated-time ordering preserves modular boundaries
The system MUST implement updated-time sync and ordering through existing data, state, and persistence owners without adding reverse dependencies.

#### Scenario: API request shape remains in data layer
- **WHEN** the app constructs a modern Memos `UpdateMemo` request with `update_time`
- **THEN** request field and `updateMask` construction MUST remain under the Memos API data layer

#### Scenario: Outbox update-time intent remains in sync state owner
- **WHEN** a memo mutation queues or processes `update_memo`
- **THEN** update-time intent parsing and forwarding MUST remain in `state/memos` mutation or sync owner code
- **AND** it MUST NOT be duplicated inside memo list widgets

#### Scenario: Query sorting does not import feature layer into state
- **WHEN** homepage sort order is passed into memo query providers or DB persistence
- **THEN** `state/memos` and `data/db` code MUST NOT import `features/memos`
- **AND** the implementation MUST NOT add new `state -> features`, `application -> features`, or `core -> state|application|features` imports
