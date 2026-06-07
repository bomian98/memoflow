## MODIFIED Requirements

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
