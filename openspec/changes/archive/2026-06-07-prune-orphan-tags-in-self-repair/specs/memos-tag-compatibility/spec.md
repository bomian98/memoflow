## MODIFIED Requirements

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
