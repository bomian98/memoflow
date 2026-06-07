## Why

服务器模式登录页当前把连接协议表现为地址输入框前缀和右侧盾牌按钮。用户需要更直接地理解并选择 `HTTP` / `HTTPS`，同时希望地址输入能容错中文输入法常见的全角冒号 `：`，避免 `localhost：5230` 这类有效意图因为字符形态失败。

本 change 聚焦登录页的服务器地址输入体验：将地址栏重构为协议选择、地址输入、安全状态展示三段式控件；协议段是明显可点击按钮；点击后通过居中弹窗选择协议；地址输入 MUST 自动将中文冒号 `：` 归一化为英文冒号 `:`。

## What Changes

- 将服务器模式登录页的服务器地址输入区改为三段式视觉结构：
  - 协议选择部分：显示 `HTTPS` 或 `HTTP`，作为明显可点击按钮。
  - 地址部分：仅输入 host、port、path 等非协议地址内容。
  - UI 展示部分：根据协议显示传输状态，例如 `HTTPS` 显示“加密”，`HTTP` 显示“未加密”。
- 点击协议选择按钮 SHALL 打开居中的协议选择弹窗，供用户选择 `HTTPS` 或 `HTTP`。
- `HTTP` 仍 MUST 保留明确风险提示；推荐使用单个协议选择弹窗承载 HTTP 风险说明，避免协议选择后再二次弹窗打断。
- 地址输入归一化是硬性要求：用户输入或粘贴全角冒号 `：` 时，地址输入值 SHALL 自动转换为半角冒号 `:`，并用于草稿保存、校验、URL 拼接和最终登录。
- 保留现有登录流程、选中 server version、PAT / password 登录、HTTPS handshake failure fallback 和 URL sanitation 行为。
- 将登录服务器地址输入的解析/归一化/拼接逻辑从 `LoginScreen` state class 中抽成 auth feature-owned helper / formatter 或等价 seam，避免继续把输入规则埋在 widget 状态里。

## Capabilities

### New Capabilities

- `login-server-url-input`: 定义服务器模式登录页的三段式地址输入、协议选择弹窗、传输状态展示和输入归一化要求。

### Modified Capabilities

- 无。

## Impact

- Affected code:
  - `memos_flutter_app/lib/features/auth/login_screen.dart`
  - 可能新增 `memos_flutter_app/lib/features/auth/login_server_url_input.dart` 或等价 auth feature-owned helper / formatter
  - `memos_flutter_app/lib/i18n/strings*.i18n.yaml`
  - 生成后的 `memos_flutter_app/lib/i18n/strings.g.dart`
- Affected tests:
  - `memos_flutter_app/test/features/auth/login_screen_lifecycle_test.dart`
  - 可能新增 `memos_flutter_app/test/features/auth/login_server_url_input_test.dart` 或等价 focused tests
- Architecture phase: `evolve_modularity`.
- Modularity checklist impact:
  - 触及 checklist `4`、`10`：登录服务器地址归一化和 URL 拼接规则不应继续散落在 screen state 中；本 change MUST 通过 auth feature-owned helper / formatter 或等价 seam 让 touched area equal or better structured。
  - 不触及 API request/response models、route adapters、version compatibility logic、`memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
  - 不得引入新的 `state -> features`、`application -> features`、`core -> state|application|features` 依赖。
  - 不得加入 subscription、billing、entitlement、receipt、paywall、StoreKit、private overlay 或其他商业逻辑。
