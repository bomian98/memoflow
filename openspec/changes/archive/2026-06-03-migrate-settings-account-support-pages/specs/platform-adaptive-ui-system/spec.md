## ADDED Requirements

### Requirement: Settings support/general pages SHALL use semantic settings UI seams

Support/general settings pages in this batch SHALL render page chrome, grouped rows, row actions, footer text, loading states, and retry actions through `SettingsPage`, `SettingsSection`, `SettingsNavigationRow`, `SettingsValueRow`, `SettingsInfoRow`, `SettingsAction`, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Feedback page is migrated

- **WHEN** `FeedbackScreen` renders submit logs, self repair, or external issue-reporting entries
- **THEN** it SHALL use settings semantic page and row seams
- **AND** it SHALL preserve the existing nested route targets, external URL, haptics behavior, and error snackbar behavior
- **AND** it SHALL NOT introduce API file edits, commercial branching, WebDAV, AI, desktop routing, account security, or server settings scope

#### Scenario: About page is migrated

- **WHEN** `AboutUsScreen` renders app identity, version information, legal/help/release/contributor entries, or debug logo tap behavior
- **THEN** page chrome and row groups SHALL use settings semantic seams
- **AND** page-specific app logo/version presentation MAY remain in the page if it uses settings/theme tokens rather than direct `MemoFlowPalette` styling
- **AND** existing external links, release notes route, donor wall route, and debug tools route behavior SHALL be preserved

#### Scenario: User general settings page is migrated

- **WHEN** `UserGeneralSettingsScreen` renders locale and default memo visibility controls
- **THEN** it SHALL use settings semantic page, section, and value row seams
- **AND** locale/visibility picker, saving guard, provider invalidation, retry action, and existing provider/API call behavior SHALL be preserved
- **AND** server-wide controls SHALL remain absent from this page

#### Scenario: Drift guardrail reflects completed support/general migration

- **WHEN** this batch is implemented
- **THEN** `feedback_screen.dart`, `about_us_screen.dart`, and `user_general_settings_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
