## ADDED Requirements

### Requirement: Login server URL input SHALL use a three-part protocol-aware control
服务器模式登录页的 server URL 输入 SHALL 使用协议选择、地址输入、传输状态展示三段式控件，让用户能直接理解当前连接协议和传输状态。

#### Scenario: HTTPS is shown as the default selected protocol
- **GIVEN** 用户进入服务器模式登录页且没有已恢复的 HTTP 草稿
- **WHEN** server URL 输入控件渲染
- **THEN** protocol segment SHALL display `HTTPS`
- **AND** address segment SHALL be empty or display only the non-protocol address suffix
- **AND** status segment SHALL indicate encrypted transport using localized wording such as “加密” / “Encrypted”

#### Scenario: HTTP draft restores protocol and status
- **GIVEN** `loginBaseUrlDraftProvider` contains an HTTP URL such as `http://localhost:5230`
- **WHEN** 登录页恢复草稿
- **THEN** protocol segment SHALL display `HTTP`
- **AND** address segment SHALL display `localhost:5230`
- **AND** status segment SHALL indicate unencrypted transport using localized wording such as “未加密” / “Unencrypted”

#### Scenario: Server URL address segment excludes protocol text
- **WHEN** 用户查看或编辑 server URL address segment
- **THEN** the address segment SHALL NOT require the user to type `http://` or `https://`
- **AND** URL composition SHALL prepend the selected protocol before validation and login
- **AND** validation messages SHALL still reject empty or invalid server addresses

### Requirement: Login protocol selection SHALL be explicit and dialog-based
协议选择 SHALL 通过明显可点击的 protocol segment 触发，并使用居中弹窗选择 `HTTPS` 或 `HTTP`。

#### Scenario: Protocol button opens a centered selection dialog
- **WHEN** 用户点击 server URL control 的 protocol segment
- **THEN** the app SHALL open a centered platform dialog
- **AND** the dialog SHALL present `HTTPS` and `HTTP` choices
- **AND** the currently selected protocol SHALL be visually indicated

#### Scenario: Selecting HTTPS uses encrypted protocol without HTTP warning
- **GIVEN** protocol dialog is open
- **WHEN** 用户选择 `HTTPS` 并确认
- **THEN** the login page SHALL use `https` for URL composition
- **AND** the status segment SHALL indicate encrypted transport
- **AND** no HTTP risk confirmation SHALL be required

#### Scenario: Selecting HTTP requires visible unencrypted risk context
- **GIVEN** protocol dialog is open
- **WHEN** 用户选择 `HTTP`
- **THEN** the dialog SHALL show visible unencrypted risk context before confirmation
- **AND** after confirmation the login page SHALL use `http` for URL composition
- **AND** the status segment SHALL indicate unencrypted transport

#### Scenario: Canceling protocol selection preserves current protocol
- **GIVEN** protocol dialog is open
- **WHEN** 用户取消或关闭弹窗
- **THEN** the previously selected protocol SHALL remain unchanged
- **AND** the composed login URL SHALL continue using the previous scheme

### Requirement: Login server URL input MUST normalize fullwidth colon characters
服务器模式登录页的 server URL 输入 MUST 自动将中文全角冒号 `：` 归一化为英文半角冒号 `:`，并将归一化结果用于草稿、校验和登录。

#### Scenario: Typing a fullwidth colon normalizes the visible address
- **WHEN** 用户在 address segment 输入 `localhost：5230`
- **THEN** the visible address value SHALL become `localhost:5230`
- **AND** validation SHALL treat the value as `localhost:5230`

#### Scenario: Pasting a URL with fullwidth colons normalizes before draft sync
- **WHEN** 用户粘贴 `http：//localhost：5230`
- **THEN** the stored login base URL draft SHALL use halfwidth colons
- **AND** the address segment SHALL use `localhost:5230` after protocol handling
- **AND** the composed login URL SHALL be equivalent to `http://localhost:5230` when HTTP is explicitly selected

#### Scenario: Normalization is used for submitted base URL
- **GIVEN** 用户输入 `localhost：5230`
- **AND** the selected protocol is `HTTPS`
- **WHEN** 用户提交登录
- **THEN** the base URL passed to session login SHALL have scheme `https`
- **AND** host `localhost`
- **AND** port `5230`

### Requirement: Existing login URL behavior SHALL be preserved
三段式 server URL 输入和中文冒号归一化 SHALL preserve existing login URL sanitation, login flow, version selection, and HTTPS failure fallback behavior.

#### Scenario: API path sanitation still removes API path segments
- **WHEN** 用户输入或粘贴 a server URL containing API path segments such as `/api/v1`
- **THEN** existing `sanitizeUserBaseUrl()` behavior SHALL continue to remove API path segments before account storage
- **AND** the user SHALL still receive the existing server URL normalized feedback where applicable

#### Scenario: HTTPS handshake failure fallback updates the three-part UI
- **GIVEN** 用户使用 `HTTPS` 登录
- **AND** login fails with a likely HTTPS handshake failure
- **WHEN** 用户在 existing fallback dialog chooses to use HTTP and try again
- **THEN** the selected protocol SHALL become `HTTP`
- **AND** the status segment SHALL indicate unencrypted transport
- **AND** the retry SHALL use `http` for URL composition

#### Scenario: Server version and login mode behavior remain unchanged
- **WHEN** 用户切换 password / token login mode, selects server version, or runs version probe flow
- **THEN** those flows SHALL continue to behave as before
- **AND** this capability SHALL NOT modify API route adapters, request/response models, or server version compatibility logic

### Requirement: Login URL input rules SHALL be testable outside screen state
登录服务器地址输入的归一化、协议剥离和 URL 拼接规则 SHALL be centralized in an auth feature-owned helper / formatter or equivalent seam so they can be tested without relying only on `LoginScreen` widget state.

#### Scenario: Auth input helper has focused coverage
- **WHEN** login server URL parsing or normalization rules change
- **THEN** focused tests SHALL cover fullwidth colon normalization, complete URL paste handling, suffix extraction, protocol composition, and invalid input behavior
- **AND** the helper SHALL NOT introduce new dependencies from lower layers to `features/*`
- **AND** the helper SHALL NOT modify API route adapters or compatibility logic
