# memos-tag-compatibility Specification

## Purpose
Preserve v0.27-compatible tags while keeping Markdown-aware extraction, tag reconciliation, and persisted tag maintenance consistent across sync, search, and local storage.
## Requirements
### Requirement: Memos v0.27 tag grammar compatibility
The app MUST recognize and preserve tag names that are valid under the Memos `0.27.x` backend tag grammar, including Unicode letters, Unicode numbers, Unicode symbols, Unicode marks, `_`, `-`, `/`, `&`, and zero-width joiner sequences, up to the supported tag length.

#### Scenario: Backend-compatible ampersand tag is preserved
- **WHEN** a v0.27 memo contains or returns the tag `science&tech`
- **THEN** the local memo, tag registry, and tag statistics MUST preserve the tag as `science&tech`

#### Scenario: Backend-compatible emoji sequence tag is preserved
- **WHEN** a v0.27 memo contains or returns a tag with a valid emoji variation selector or ZWJ sequence
- **THEN** the local memo, tag registry, and tag statistics MUST preserve the full tag sequence without stripping valid Unicode marks or joiners

#### Scenario: Hierarchical tag remains hierarchical
- **WHEN** a v0.27 memo contains or returns a hierarchical tag such as `work/project-2026`
- **THEN** the app MUST preserve the slash-separated hierarchy as a single tag path

### Requirement: V0.27 memo tag payload handling
The app MUST parse non-empty `tags` arrays from Memos `0.27.x` `ListMemos` responses and carry those values through remote sync into local storage and tag display data.

#### Scenario: Modern v0.27 list response includes non-empty tags
- **WHEN** `GET /api/v1/memos` returns a v0.27 memo JSON object with `tags: ["science&tech"]`
- **THEN** `Memo.fromJson` and the v0.27 API facade MUST expose `memo.tags` containing `science&tech`

#### Scenario: Remote sync receives v0.27 tags
- **WHEN** remote sync processes a v0.27 memo with non-empty backend `Memo.tags`
- **THEN** the local `memos.tags`, `tags`, `memo_tags`, and `tag_stats_cache` data MUST contain the backend-compatible tag path

### Requirement: Tag grammar remains a shared lower-layer seam
Tag parsing, Markdown-aware extraction, normalization, and write-path reconciliation behavior MUST remain centralized in stable lower-layer code and MUST NOT be duplicated in feature screens, widgets, or UI-only helpers.

#### Scenario: Feature UI renders tag data
- **WHEN** a feature screen, drawer, editor, or widget needs tag display or suggestions
- **THEN** it MUST consume shared tag data or shared tag helpers instead of implementing its own v0.27-specific parser

#### Scenario: Sync and search normalize tags
- **WHEN** state or data code normalizes tags for sync, search, or persistence
- **THEN** it MUST use the shared tag grammar seam so behavior remains consistent across API, sync, local DB, and UI surfaces

#### Scenario: Memo write paths reconcile tags
- **WHEN** memo create, edit, import, or sync code persists memo content and tag state
- **THEN** it SHOULD use a shared tag reconciliation seam that updates canonical tag paths, tag rows, `memo_tags`, redundant `memos.tags`, search, and statistics consistently
- **AND** call sites SHOULD NOT duplicate the low-level reconciliation sequence

### Requirement: Persisted memo tag representations remain consistent
The app SHALL treat `memo_tags` as the relationship and statistics source of truth while keeping `memos.tags` synchronized as a compatibility, search, and sync representation.

#### Scenario: Memo write stores canonical tags
- **WHEN** a memo is created or updated with extracted or provided tags
- **THEN** the app MUST resolve canonical tag paths
- **AND** it MUST update `memo_tags` with the matching tag ids
- **AND** it MUST write `memos.tags` with the same canonical paths
- **AND** search/statistics data MUST reflect the same canonical paths

#### Scenario: Tag hierarchy changes affect memo tags
- **WHEN** a tag is renamed, moved, or deleted in a way that changes canonical paths
- **THEN** affected memo tag relationships and redundant text/search/statistics representations MUST remain consistent with the resulting canonical paths

### Requirement: Stored tags can be recomputed under current extraction rules
The app SHALL provide a controlled maintenance operation that can recompute persisted memo tags from memo content using the current Markdown-aware extraction and reconciliation rules, and SHALL prune local tag registry rows that become orphaned after that explicit recompute.

#### Scenario: Historical code-context false positive is repaired
- **GIVEN** an existing memo has a persisted false tag that only appears inside a code context
- **WHEN** the maintenance operation recomputes tags for that memo
- **THEN** the false tag MUST be removed from `memo_tags`, `memos.tags`, search, and tag statistics
- **AND** valid tags outside code contexts MUST remain persisted

#### Scenario: Orphan tag rows are removed during explicit maintenance
- **GIVEN** a tag row is not referenced by any `memo_tags` row after maintenance recomputes memo tags from current content
- **AND** the tag row has no child tag rows
- **WHEN** the explicit maintenance operation prunes orphan tags
- **THEN** the tag row MUST be removed from `tags`
- **AND** related `tag_aliases` MUST NOT continue resolving to the removed tag
- **AND** tag display data MUST NOT include the removed tag as a `count=0` entry

#### Scenario: Maintenance avoids silent policy loss
- **WHEN** a recompute operation could remove stored tags that are not present in memo content
- **THEN** the operation MUST be explicit, documented, or otherwise scoped so users are not surprised by silent tag removal

### Requirement: Content fallback extraction uses strict tag zones
当后端 tag payload 缺失、为空、陈旧，或本地-only memo 内容需要从正文推导标签时，app MUST 只从严格标签区提取标签。严格标签区仅包含 memo 的首个和最后一个非空内容行；候选行 trim 后 MUST 以一个或多个空白分隔的 `#tag` token 开头。tag prefix 后 MAY 跟随普通说明文字，但说明文字中的后续 `#...` MUST NOT 被提取为标签。普通正文中夹带的 `#...` MUST NOT 被提取为标签。

#### Scenario: First and last tag-zone lines are extracted
- **WHEN** memo content has first non-empty line `#openwrt #build`, middle body text, and last non-empty line `#router`
- **THEN** fallback extraction MUST return `openwrt`, `build`, and `router`
- **AND** local tag storage, search, and statistics MUST reflect only those extracted tag paths when no backend tag payload is available

#### Scenario: Leading tag prefix with trailing prose is extracted
- **WHEN** memo content has first or last non-empty line `#测试文本 测试文本`
- **THEN** fallback extraction MUST return `测试文本`
- **AND** the trailing prose `测试文本` MUST remain normal memo content

#### Scenario: Later prose hash after tag prefix is ignored
- **WHEN** memo content has first or last non-empty line `#first text #ignored`
- **THEN** fallback extraction MUST return `first`
- **AND** fallback extraction MUST NOT include `ignored`

#### Scenario: Body prose hash is ignored
- **WHEN** memo content contains ordinary prose such as `测试文本 #这是测试文本`
- **THEN** fallback extraction MUST NOT create `这是测试文本` as a tag
- **AND** the prose content MUST remain unchanged

#### Scenario: Middle body tag is ignored
- **WHEN** memo content has a valid-looking `#middle-tag` only in a middle paragraph, list item, blockquote, or table cell
- **THEN** fallback extraction MUST NOT include `middle-tag`

#### Scenario: Non-zone first or last line is ignored
- **WHEN** the first or last non-empty line contains prose plus a hash fragment such as `今天记录一下 #生活`
- **THEN** fallback extraction MUST NOT include `生活`

#### Scenario: Protected Markdown contexts remain ignored
- **WHEN** memo content contains code blocks, inline code, links, images, or URL fragments with `#...`
- **THEN** fallback extraction MUST NOT create tags from those protected contexts
- **AND** valid tags in strict tag-zone lines outside those protected contexts MUST still be extracted

#### Scenario: Backend tag payload remains authoritative
- **WHEN** remote sync receives a memo with a non-empty backend `Memo.tags` payload
- **THEN** local storage MUST preserve the backend tag payload even if those tags are not present in strict tag-zone lines

### Requirement: Memo tag decoration follows strict tag zones
Memo HTML rendering MUST decorate clickable tag chips only for tags that are in strict tag-zone lines. Display decoration MUST NOT make ordinary prose hash fragments look like persisted or navigable tags.

#### Scenario: Prose hash is not decorated
- **WHEN** memo content contains `测试文本 #这是测试文本`
- **THEN** rendered memo HTML MUST NOT wrap `#这是测试文本` with the memo tag decoration span

#### Scenario: Tag-zone line is decorated
- **WHEN** memo content contains a strict tag-zone prefix such as `#openwrt #build body #ignored`
- **THEN** rendered memo HTML SHOULD decorate `#openwrt` and `#build` as memo tags
- **AND** rendered memo HTML MUST NOT decorate `#ignored`

