# memo-card-markdown-preview Specification

## Purpose
Define how memo card previews preserve Markdown and HTML rendering semantics while still using plain text only for preview measurement and affordance decisions.

## Requirements
### Requirement: Card preview renders Markdown semantics from source
The system SHALL render home/list memo card and draft card preview bodies from Markdown/HTML source that preserves authored inline semantics instead of from plain-text-normalized preview content.

#### Scenario: Home card renders inline HTML semantics
- **GIVEN** a home/list memo card contains authored content with inline HTML such as `<sup>2</sup>` or `<sub>2</sub>`
- **WHEN** the card preview is rendered without opening the detail page
- **THEN** the preview renderer receives source that still contains those inline HTML elements
- **AND** the visible preview renders the corresponding Markdown/HTML semantics rather than plain text only

#### Scenario: Home card renders inline code semantics
- **GIVEN** a home/list memo card contains authored inline Markdown code
- **WHEN** the card preview is rendered without opening the detail page
- **THEN** the preview renderer receives source that still contains the inline code delimiters or equivalent code semantics
- **AND** the visible preview renders inline code styling rather than ordinary paragraph text

#### Scenario: Draft card follows the same preview rendering rule
- **GIVEN** a draft box card contains authored Markdown/HTML semantics
- **WHEN** the draft card preview is rendered
- **THEN** the draft card uses the same source-preserving preview rule as a home/list memo card

### Requirement: Plain preview normalization is limited to measurement
The system SHALL use plain-text preview normalization only for length measurement, empty fallback, reference summaries, and expand/collapse affordance decisions. It MUST NOT use the normalized plain text as the default `MemoMarkdown` rendering source.

#### Scenario: Short rich content is not plain-text-normalized before rendering
- **GIVEN** a memo body is short enough that the card does not need the expanded/collapsed toggle
- **WHEN** the home/list card body is rendered
- **THEN** the system MAY use normalized plain text to decide that no toggle is needed
- **BUT** the `MemoMarkdown` rendering source SHALL be the source-preserving preview content

#### Scenario: Long rich content uses measurement without replacing render source
- **GIVEN** a memo body is long enough to require a collapsed preview
- **WHEN** the home/list card body is rendered in collapsed state
- **THEN** the system SHALL use plain preview measurement to decide that the toggle is needed
- **AND** the collapsed renderer source SHALL remain source-preserving Markdown/HTML content

### Requirement: Collapsed preview preserves renderer path and accepts clipping
The system SHALL keep collapsed card previews on the existing `MemoMarkdown` renderer path with `maxLines`-based clipping. It MUST NOT replace collapsed Markdown rendering with a custom rich `TextSpan` preview.

#### Scenario: Collapsed home card uses MemoMarkdown maxLines
- **GIVEN** a long memo body requires a collapsed preview
- **WHEN** the home/list card renders that body
- **THEN** the card SHALL render a `MemoMarkdown` preview with `maxLines` set to the card preview limit
- **AND** the implementation SHALL NOT require line-safe truncation or custom rich preview rendering

#### Scenario: Code fence is not truncated before rendering
- **GIVEN** a memo body contains a fenced code block
- **WHEN** the card preview is collapsed
- **THEN** the renderer source SHALL NOT be rune-truncated in a way that can split the authored code fence before `MemoMarkdown` parses it
- **AND** visual clipping MAY still limit the rendered height

### Requirement: Reference collapsing keeps render source and measurement consistent
The system SHALL apply `collapseReferences` consistently to both preview measurement and preview render source. The transform MUST preserve Markdown/HTML semantics in non-quoted content.

#### Scenario: Quoted lines affect both toggle decision and render source
- **GIVEN** home/list card preferences enable reference collapsing
- **AND** a memo contains non-quoted Markdown content and quoted lines
- **WHEN** the card preview plan is built
- **THEN** quoted lines SHALL be excluded or summarized in both the measurement input and the render source
- **AND** non-quoted Markdown/HTML semantics SHALL remain available to `MemoMarkdown`

#### Scenario: Cache key changes with reference collapse behavior
- **GIVEN** a memo card has already rendered with reference collapsing disabled
- **WHEN** reference collapsing is enabled and the card renders again
- **THEN** the card render cache SHALL NOT reuse a stale Markdown source built for the previous reference-collapse setting

### Requirement: Preview planning is reusable outside widget build methods
The system SHALL keep card preview measurement and render-source selection in a feature-local helper or equivalent seam, rather than duplicating source-selection rules inside separate widget build methods.

#### Scenario: Home card and draft card share preview planning behavior
- **WHEN** home/list memo cards and draft cards need preview body text
- **THEN** both surfaces SHALL obtain measurement/render-source behavior from the shared feature-local preview planning rule
- **AND** neither surface SHALL implement a separate, divergent Markdown-to-plain-text rendering decision in its widget build method
