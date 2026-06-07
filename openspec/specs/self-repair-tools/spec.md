# self-repair-tools Specification

## Purpose
Defines the user-facing help, diagnostics, self-repair, and storage-space maintenance tools exposed from settings. These tools repair or clear safe local derived data without deleting user content, account data, preferences, backups, sync queues, or remote server data.
## Requirements
### Requirement: Help and diagnostics provides a self-repair entry
The system SHALL expose user-triggered local repair tools from the settings help and diagnostics area.

#### Scenario: User opens self repair from help and diagnostics
- **WHEN** the user opens `Settings -> Help & Diagnostics`
- **THEN** the help and diagnostics page SHALL provide a self-repair entry
- **AND** activating the entry SHALL open a dedicated self-repair page
- **AND** the entry SHALL NOT immediately mutate local data

### Requirement: Help and diagnostics exposes storage space as a dedicated page
The system SHALL expose MemoFlow storage diagnostics from `Settings -> Help & Diagnostics -> Storage Space` rather than from the self-repair action list.

#### Scenario: User sees help and diagnostics from settings
- **WHEN** the user opens `Settings`
- **THEN** the settings home SHALL show a `Help & Diagnostics` entry
- **AND** the entry SHALL replace the previous user-facing `Feedback` settings-home label for this diagnostic group
- **AND** existing feedback, log export, and self-repair capabilities SHALL remain reachable from the diagnostic group

#### Scenario: User opens storage space from help and diagnostics
- **WHEN** the user opens `Settings -> Help & Diagnostics`
- **THEN** the page SHALL provide a `Storage Space` navigation entry
- **AND** activating the entry SHALL push a dedicated storage-space page
- **AND** the storage-space page SHALL NOT be embedded inside `Self Repair`

#### Scenario: Self repair no longer owns media cache cleanup UI
- **WHEN** the user opens `Settings -> Help & Diagnostics -> Self Repair`
- **THEN** the self-repair page SHALL provide local repair actions for abnormal tags, search index, and statistics cache
- **AND** the self-repair page SHALL NOT show a media-cache cleanup button
- **AND** the self-repair page SHALL NOT show media-cache aggregate/category rows

### Requirement: Storage space summarizes MemoFlow known usage
The system SHALL summarize MemoFlow known local usage on the dedicated storage-space page without reporting other apps' usage.

#### Scenario: User sees MemoFlow known usage total
- **WHEN** the storage-space summary is available
- **THEN** the storage-space page SHALL show MemoFlow known usage total
- **AND** the page SHALL describe the value as MemoFlow known usage rather than total system app storage
- **AND** the page SHALL NOT show other apps' used space as a category, segment, or amount

#### Scenario: Device capacity is available
- **WHEN** device total capacity is available from the platform adapter
- **THEN** the storage-space page MAY show MemoFlow known usage as a percentage of device capacity
- **AND** the percentage SHALL use MemoFlow known usage as the numerator
- **AND** the page SHALL NOT derive or display other apps' usage from the remaining capacity

#### Scenario: Device capacity is unavailable
- **WHEN** device total capacity is unavailable, unsupported, or fails to load
- **THEN** the storage-space page SHALL still show MemoFlow known usage total and category rows
- **AND** the page SHALL gracefully omit or downgrade the device-capacity percentage
- **AND** cache cleanup SHALL remain available when the cache maintenance seam is available

#### Scenario: User sees storage categories
- **WHEN** the storage-space summary is available
- **THEN** the page SHALL show category-level sizes for cache, note content, note images, note videos, note audio, and note files
- **AND** note content SHALL be estimated from local memo content bytes
- **AND** note image/video/audio/file categories SHALL be estimated from attachment metadata rather than filesystem-wide scans
- **AND** the page SHALL NOT show a browsable cache gallery
- **AND** the page SHALL NOT expose individual cached image selection, URL selection, per-image deletion controls, or per-attachment cleanup controls

### Requirement: Storage space clears only safe cache data
The system SHALL allow active cleanup only for safe MemoFlow cache data from the storage-space page.

#### Scenario: User sees cache cleanup action
- **WHEN** the user opens the storage-space page
- **THEN** the cache category SHALL provide an active cleanup control
- **AND** note content, note images, note videos, note audio, and note files SHALL NOT provide active cleanup controls

#### Scenario: User confirms cache cleanup
- **WHEN** the user confirms cache cleanup from the storage-space page
- **THEN** the system SHALL clear safe media-derived caches including network image cache, Flutter image memory cache, video thumbnail cache, and explicitly allowlisted media temporary caches
- **AND** memo content, accounts, preferences, local library source files, attachment source files, WebDAV backups, pending sync queues, and remote server data SHALL NOT be deleted by this action
- **AND** cached media MAY be downloaded or regenerated again when the user views related content later
- **AND** the storage-space summary SHALL refresh after cleanup completes

#### Scenario: User cancels cache cleanup
- **WHEN** the cache cleanup confirmation is shown
- **AND** the user cancels the confirmation
- **THEN** no cache cleanup SHALL run
- **AND** cached media files SHALL remain unchanged by this action

#### Scenario: Cache cleanup reports partial failures
- **WHEN** one allowlisted cache category fails to clear but another category completes
- **THEN** the page SHALL show a recoverable localized failure or partial-failure result
- **AND** the user SHALL remain able to export logs or use the existing feedback/reporting path
- **AND** successful category cleanup SHALL NOT be rolled back

### Requirement: Storage-space maintenance preserves modular boundaries
The system MUST implement storage statistics and cache cleanup through reusable maintenance seams rather than embedding cache-manager, database-summary, platform-capacity, or filesystem logic in settings widgets.

#### Scenario: Settings UI routes storage-space intent only
- **WHEN** the storage-space UI is added
- **THEN** settings widgets MUST only render localized copy, summary state, confirmations, operation state, and user actions
- **AND** settings widgets MUST NOT directly import `DefaultCacheManager`, `PaintingBinding`, `path_provider`, media cache helper internals, platform capacity internals, DB persistence helpers, or filesystem directory traversal utilities for cleanup/statistics

#### Scenario: Maintenance seam owns allowlisted cache categories
- **WHEN** cache size is calculated or cache cleanup runs
- **THEN** a state/application maintenance seam MUST own the allowlist of cache categories
- **AND** the implementation MUST NOT recursively clear broad temporary, support, documents, account, database, local library, or sync directories

#### Scenario: Storage summary seam owns MemoFlow usage categories
- **WHEN** MemoFlow known usage is calculated
- **THEN** a state/application/data seam MUST own memo-content and attachment-size aggregation
- **AND** the settings UI MUST NOT parse memo rows, attachment JSON, raw SQLite rows, or attachment metadata directly
- **AND** the implementation SHOULD define deterministic handling for missing attachment sizes and duplicate attachment identities

#### Scenario: No storage-space reverse dependency is introduced
- **WHEN** storage-space diagnostics are implemented during `evolve_modularity`
- **THEN** the implementation MUST NOT introduce new `state -> features`, `application -> features`, or `core -> state|application|features` imports
- **AND** reusable storage summary or cache cleanup logic SHALL NOT be hidden inside screen or widget files

### Requirement: Self-repair page offers explicit local maintenance actions
The system SHALL show repair actions as explicit user-triggered operations rather than a broad database reset.

#### Scenario: User views available repair actions
- **WHEN** the self-repair page is displayed
- **THEN** it SHALL offer separate actions for abnormal tag cleanup, local keyword search index rebuild, and stats cache rebuild
- **AND** it SHALL explain that these operations repair local derived data
- **AND** it SHALL NOT offer a full local database reset in this change

#### Scenario: Repair action is confirmed before mutation
- **WHEN** the user starts a repair action that mutates local derived data
- **THEN** the system SHALL ask for confirmation before running the operation
- **AND** the confirmation SHALL name the affected derived data
- **AND** cancellation SHALL leave local data unchanged

### Requirement: Abnormal tag cleanup recomputes stored tags from memo content
The system SHALL provide a user-triggered abnormal tag cleanup action that recomputes persisted memo tags from memo content using the current shared tag extraction and reconciliation rules, then prunes local orphan tag registry rows that are no longer reachable from any memo tag relationship.

#### Scenario: Historical code-context false positive is cleaned
- **GIVEN** an existing memo has a persisted tag that only appears inside a Markdown code context
- **WHEN** the user confirms abnormal tag cleanup
- **THEN** the false tag SHALL be removed from `memo_tags`
- **AND** it SHALL be removed from redundant `memos.tags`
- **AND** local search and stats data SHALL no longer expose the false tag after repair-dependent refresh completes
- **AND** valid tags in user-visible memo prose SHALL remain persisted

#### Scenario: Strict recompute policy is visible
- **WHEN** the abnormal tag cleanup confirmation is shown
- **THEN** the system SHALL explain that memo tags will be rebuilt from current memo body `#tag` text
- **AND** it SHALL explain that stored tags not present in the memo body may be removed

#### Scenario: Orphan tag registry rows are pruned after recompute
- **GIVEN** a local tag row has no `memo_tags` association after memo tags are recomputed from current memo content
- **AND** the tag has no child tag rows
- **WHEN** the user confirms abnormal tag cleanup
- **THEN** the tag row SHALL be deleted from `tags`
- **AND** related rows in `tag_aliases` SHALL be removed or otherwise prevented from resolving to the deleted tag
- **AND** the Tags page SHALL NOT list that tag as a `count=0` result after repair refresh completes

#### Scenario: Hierarchical orphan tags are pruned leaf first
- **GIVEN** a hierarchy of tag rows has no remaining `memo_tags` associations
- **WHEN** the user confirms abnormal tag cleanup
- **THEN** orphan child tags SHALL be pruned before their parent tags
- **AND** parent tags that become leaf orphans after child pruning SHALL also be pruned before the repair operation completes

#### Scenario: Referenced tags are preserved
- **GIVEN** a tag row is still referenced by at least one memo tag relationship after recompute
- **WHEN** the user confirms abnormal tag cleanup
- **THEN** the tag row SHALL remain in `tags`
- **AND** its memo relationship, redundant `memos.tags`, search data, and tag statistics SHALL remain consistent

#### Scenario: Orphan pruning remains explicit self-repair behavior
- **WHEN** remote sync completes without the user confirming abnormal tag cleanup
- **THEN** this change SHALL NOT require automatic orphan tag pruning solely as a sync completion side effect
- **AND** user-created empty tags SHALL NOT be removed merely because a normal sync cycle completed

### Requirement: Search index rebuild restores local keyword search data
The system SHALL provide a user-triggered search index rebuild action for local keyword search persistence.

#### Scenario: User rebuilds local search index
- **WHEN** the user confirms local keyword search index rebuild
- **THEN** the system SHALL rebuild local search persistence used for literal keyword search
- **AND** memo content, memo metadata, accounts, preferences, attachments, and remote server data SHALL NOT be deleted by this action

#### Scenario: Search semantics are preserved after rebuild
- **WHEN** local keyword search index rebuild completes
- **THEN** memo search SHALL continue to use the existing literal substring matching contract
- **AND** existing state, tag, date range, advanced filter, ordering, and result-limit behavior SHALL remain constraints on visible results

### Requirement: Stats cache rebuild restores derived statistics
The system SHALL provide a user-triggered stats cache rebuild action for local statistics derived from memo data.

#### Scenario: User rebuilds stats cache
- **WHEN** the user confirms stats cache rebuild
- **THEN** the system SHALL rebuild derived local statistics including heatmap data, tag statistics, and summary counters
- **AND** memo content, memo metadata, accounts, preferences, attachments, and remote server data SHALL NOT be deleted by this action

### Requirement: Self-repair reports operation state
The system SHALL provide clear operation state for self-repair actions.

#### Scenario: Repair action is running
- **WHEN** a self-repair action is running
- **THEN** the page SHALL show a busy state for that action
- **AND** it SHOULD prevent starting conflicting repair actions until the current action finishes

#### Scenario: Repair action succeeds
- **WHEN** a self-repair action completes successfully
- **THEN** the page SHALL show a localized success result naming the completed repair
- **AND** app-visible derived data SHALL refresh through existing change notification behavior

#### Scenario: Repair action fails
- **WHEN** a self-repair action fails
- **THEN** the page SHALL show a localized recoverable error state
- **AND** the user SHALL remain able to export logs or use the existing feedback/reporting path

### Requirement: Self-repair preserves modular boundaries
The system MUST implement self-repair orchestration through reusable state/application and data-layer seams rather than embedding maintenance logic in settings widgets.

#### Scenario: UI routes user intent only
- **WHEN** self-repair UI code is added or changed
- **THEN** it MUST only render localized copy, confirmations, operation state, and user actions
- **AND** it MUST NOT import focused DB persistence helpers such as `MemoSearchDbPersistence` or `TagDbPersistence`
- **AND** it MUST NOT manually duplicate tag, search, or stats rebuild sequences

#### Scenario: Repair service uses approved database facade
- **WHEN** a self-repair action runs
- **THEN** it MUST call a state/application service or mutation seam that uses approved `AppDatabase` facade methods
- **AND** `AppDatabase` SHALL remain responsible for desktop write-proxy dispatch, public maintenance facade compatibility, and data-change notification policy

#### Scenario: No reverse dependency is introduced
- **WHEN** self-repair tools are implemented during `evolve_modularity`
- **THEN** the implementation MUST NOT introduce new `state -> features`, `application -> features`, or `core -> state|application|features` imports
