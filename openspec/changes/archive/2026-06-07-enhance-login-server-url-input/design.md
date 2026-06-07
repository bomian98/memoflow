## Context

当前登录页相关路径主要是：

```text
LoginScreen
  ├─ _useHttps
  ├─ _baseUrlController
  ├─ _restoreBaseUrlDraft()
  ├─ _normalizeBaseUrlSuffix()
  ├─ _composeBaseUrlString()
  ├─ _handleProtocolChanged()
  └─ _resolveBaseUrl()
       └─ sanitizeUserBaseUrl()
```

现状已经有 `HTTPS` / `HTTP` 状态、HTTP 风险确认、HTTPS 握手失败后切到 HTTP 的帮助弹窗，以及登录草稿保存。问题主要在表达层：协议切换隐藏在右侧盾牌图标里，用户需要读提示文字才能理解；地址输入对中文冒号不容错。

## Goals / Non-Goals

**Goals:**

- 登录页服务器地址输入区 SHALL 呈现为协议选择、地址输入、传输状态展示三段式。
- 协议选择部分 SHALL 是明显可点击按钮，点击后打开居中弹窗选择 `HTTPS` / `HTTP`。
- 地址输入 MUST 自动将中文冒号 `：` 归一化为英文冒号 `:`，覆盖输入、粘贴、草稿、校验和提交。
- `HTTPS` 状态文案 SHOULD 使用“加密”或等价传输语义；`HTTP` 状态文案 SHOULD 使用“未加密”或等价风险语义，避免把 HTTPS 说成绝对“安全”。
- 保留现有 URL sanitation、server version selector、登录模式切换、probe gate、password / PAT 登录和 handshake fallback 行为。
- 通过 focused tests 锁定协议弹窗、HTTP 选择、中文冒号归一化和 URL 拼接结果。

**Non-Goals:**

- 不改变 Memos API 登录接口、route adapter、server version compatibility、probe service 或 request/response models。
- 不改变本地模式 onboarding、语言选择、server settings 页面或已登录后的账号设置。
- 不新增自动探测服务器支持 `HTTP` / `HTTPS` 的网络探测。
- 不新增商业/private overlay、subscription、billing、entitlement、paywall 或 StoreKit 逻辑。
- 不在本 change 中重做登录页整体信息架构、登录方式、server version selection 或视觉主题。

## Decisions

1. **三段式地址栏替代前缀文字 + 盾牌图标。**

   - 方案：将当前 `_buildField(prefixText, suffixIcon)` 的 server URL special case 抽为专用地址输入 widget / builder，内部横向排列 protocol button、`TextFormField`、status chip。
   - 理由：server URL 输入具有协议选择和安全状态，不再适合通用 `_buildField` 的 prefix/suffix 形态。
   - Alternative considered: 保留右侧盾牌但放大。该方案仍让协议入口与实际协议文字分离，用户需要额外理解图标含义。

2. **协议选择使用单个居中弹窗。**

   - 方案：点击协议按钮后调用现有 `showPlatformDialog`，在 `AlertDialog` 中展示 `HTTPS` 和 `HTTP` 两个选择项。`HTTP` 选项包含未加密风险说明；确认后更新 `_useHttps`。
   - 理由：已有登录页弹窗基础设施足够，且居中弹窗符合用户要求。
   - Alternative considered: 点击 HTTP 后再弹一次确认。该方案风险提示明确，但交互被拆成两段，容易显得笨重。

3. **HTTP 风险提示保持强语义，但不使用商业或权限逻辑。**

   - 方案：协议弹窗中 `HTTP` 行显示 warning icon 和“未加密，仅建议用于本机、局域网或临时测试”等文案；选择 HTTP 时不需要新增 capability、subscription 或平台判断。
   - 理由：这是连接安全提示，不是功能授权或商业分支。

4. **中文冒号归一化作为输入规则，而不是提交前补救。**

   - 方案：为地址输入添加 `TextInputFormatter` 或等价 formatter，在输入/粘贴时将 `：` 替换为 `:`，并保持光标位置稳定。归一化后的值同步到 `loginBaseUrlDraftProvider`，校验和 `_resolveBaseUrl()` 使用归一化结果。
   - 理由：用户应该立即看到地址被修正，草稿也应保存可提交的地址。
   - Alternative considered: 仅在 `_resolveBaseUrl()` 前替换。该方案可以登录成功，但界面和草稿仍保留错误字符，容易造成困惑。

5. **提取 auth feature-owned input helper / formatter。**

   - 方案：把 `_normalizeBaseUrlSuffix()`、suffix extraction、compose/parse helpers 和 fullwidth-colon formatter 抽到 `features/auth` 下的小 helper，或通过等价私有 widget/helper 文件集中承载。
   - 理由：这些规则已经超出纯渲染逻辑；提取后可单独测试，也符合 `evolve_modularity` 阶段对 touched area 的结构改善要求。
   - Alternative considered: 继续把所有规则写在 `_LoginScreenState`。该方案改动最少，但会让 screen state 继续膨胀。

6. **粘贴完整 URL 的处理保持保守。**

   - 方案：如果地址输入中包含 `http://` 或 `https://`，继续剥离协议到地址部分，并依据现有恢复/规范化路径保持最终 URL 可用。实现 SHOULD 避免让用户通过粘贴 `http://` 绕过 HTTP 风险提示。
   - 理由：三段式 UI 的协议应由协议按钮明确表达，HTTP 风险也应被用户看见。

## Proposed Interaction

```text
服务器地址
┌───────────┬──────────────────────────────┬───────────┐
│ HTTPS  ▾  │ localhost:5230               │  加密     │
└───────────┴──────────────────────────────┴───────────┘
```

协议弹窗：

```text
选择连接协议

● HTTPS
  加密连接，推荐使用

○ HTTP
  未加密，仅建议用于本机、局域网或临时测试

[取消]                         [使用所选协议]
```

## Dependency Direction

- Before: `LoginScreen` 同时承担渲染、协议 UI、server URL suffix parsing、URL composition 和草稿同步。
- After: `LoginScreen` 仍是 UI 入口，但 server URL 输入规则 SHOULD 由 auth feature-owned helper / formatter 承载；helper 不依赖 `state/*`、`application/*`、`data/api/*` 或其他 feature screen。
- `state/system/login_draft_provider.dart` 继续只保存登录草稿字符串；不新增 `state -> features` 依赖。
- `core/url.dart` 可继续负责通用 URL sanitation；本 change 不要求修改通用 API URL 逻辑。

本 change 触及 login UI 和输入规则。在 `evolve_modularity` 阶段，提取 auth input helper / formatter 和 focused tests 使 touched area equal or better structured。

## Risks / Trade-offs

- [Risk] 三段式地址栏在小屏幕上挤压地址输入。Mitigation: protocol button 和 status chip 使用稳定最小宽度，地址输入使用 `Expanded`，状态文案可在极窄宽度下使用 icon-only tooltip 或短文案。
- [Risk] 弹窗选择 HTTP 后用户忽略风险。Mitigation: HTTP 选项使用 warning icon 和未加密说明，状态 chip 持续显示未加密。
- [Risk] 输入 formatter 影响光标位置。Mitigation: formatter 只做等长替换 `：` -> `:`，保持 selection/composing offset。
- [Risk] 完整 URL 粘贴和协议按钮状态出现不一致。Mitigation: 提取 parse helper 并增加 tests 覆盖 `http://host`、`https://host`、`host：5230`、`http：//host：5230`。
- [Risk] 新增本地化键后生成文件遗漏。Mitigation: tasks 明确运行 i18n generator，并在 focused widget tests 中使用 generated strings。
