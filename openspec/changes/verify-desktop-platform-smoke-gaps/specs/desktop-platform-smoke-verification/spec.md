## ADDED Requirements

### Requirement: Deferred desktop smoke gaps remain explicit
The system SHALL track deferred desktop platform smoke checks as explicit OpenSpec tasks when a source change has completed its code, automated tests, architecture guardrails, and OpenSpec validation but still requires real Windows or macOS runtime confirmation.

#### Scenario: Source change transfers manual verification
- **WHEN** a completed-code desktop change still has manual platform smoke tasks
- **THEN** those tasks SHALL be represented in a follow-up verification change rather than being marked as verified in the source change

#### Scenario: Source task records transfer instead of verification
- **WHEN** a source change task is checked after transfer
- **THEN** the task text SHALL state that the item is unconfirmed manually and transferred to the verification change

### Requirement: Verification tasks preserve source context
The system SHALL preserve the source change name, affected platform, and concrete behavior to confirm for every deferred desktop smoke item.

#### Scenario: Reviewer inspects a transferred smoke item
- **WHEN** a reviewer reads the verification task list
- **THEN** the reviewer SHALL be able to identify the original change and the exact Windows/macOS behavior that remains unconfirmed

### Requirement: Verification change does not imply runtime changes
The system SHALL treat desktop smoke verification tracking as OpenSpec process work only unless a failed smoke check identifies a separate implementation defect.

#### Scenario: Smoke check reveals a defect
- **WHEN** a manual smoke check fails
- **THEN** the defect SHALL be handled by a targeted implementation change or by reopening the relevant source change before claiming the smoke task is complete
