## ADDED Requirements

### Requirement: Collapsed card Markdown previews remain image-free
The system SHALL preserve Markdown/HTML inline semantics in collapsed home/list card previews while keeping inline image rendering disabled. Collapsed previews MUST NOT start remote image, local file image, or attachment image requests from Markdown or raw HTML image syntax.

#### Scenario: Collapsed card strips Markdown image requests
- **GIVEN** a home/list memo card contains Markdown image syntax and other Markdown/HTML inline semantics
- **WHEN** the card is rendered in collapsed preview state
- **THEN** inline image rendering SHALL remain disabled for the preview
- **AND** the Markdown image SHALL NOT start a remote or local image request
- **AND** the non-image Markdown/HTML semantics SHALL remain eligible for normal preview rendering

#### Scenario: Collapsed card strips raw HTML image requests
- **GIVEN** a home/list memo card contains a raw HTML `<img>` tag and other inline HTML semantics such as `<sup>` or `<sub>`
- **WHEN** the card is rendered in collapsed preview state
- **THEN** the raw HTML image SHALL NOT start a remote or local image request
- **AND** non-image inline HTML semantics SHALL remain eligible for normal preview rendering

#### Scenario: Expanded article image behavior remains unchanged
- **GIVEN** a memo card supports expanded article body inline image rendering under the existing image policy
- **WHEN** the user expands that card
- **THEN** existing expanded inline image behavior SHALL remain governed by `MemoInlineImageSyntax` and the scoped image allowlist requirements
