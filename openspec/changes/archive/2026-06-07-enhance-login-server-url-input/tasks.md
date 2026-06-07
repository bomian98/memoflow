## 1. 范围确认与基线

- [x] 1.1 确认本 change 只影响服务器模式登录页的 server URL 输入、协议选择 UI、协议状态展示和地址输入归一化。
- [x] 1.2 记录当前 server URL 输入路径：`LoginScreen` -> `_useHttps` / `_baseUrlController` / `_composeBaseUrlString()` / `_resolveBaseUrl()` / `sanitizeUserBaseUrl()`。
- [x] 1.3 确认本 change 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、API request/response models、route adapters、version compatibility logic、商业/private hooks 或 paid-feature 逻辑。

## 2. Auth input seam / normalization

- [x] 2.1 新增或提取 auth feature-owned helper / formatter，集中处理登录服务器地址 suffix 归一化、完整 URL 剥离、URL 拼接和中文冒号 `：` -> 英文冒号 `:`。
- [x] 2.2 确保地址输入归一化覆盖输入、粘贴、草稿同步、校验和提交路径。
- [x] 2.3 保持 `loginBaseUrlDraftProvider` 存储归一化后的完整 URL 字符串。
- [x] 2.4 保持 `sanitizeUserBaseUrl()` 的现有 API path 清理行为，不扩大到 API route / adapter 改动。
- [x] 2.5 避免新增 `state -> features`、`application -> features`、`core -> state|application|features` 依赖。

## 3. 三段式 server URL UI

- [x] 3.1 将 server URL 输入替换为专用三段式控件：protocol button、address input、transport status chip。
- [x] 3.2 protocol button 显示当前 `HTTPS` / `HTTP`，具有明显可点击 affordance，并在 busy 状态禁用。
- [x] 3.3 address input 只显示非协议地址内容，并保留 URL keyboard、placeholder、validation 和 focus 行为。
- [x] 3.4 transport status chip 根据协议展示“加密”/“未加密”或等价本地化短文案；不要把 `HTTPS` 描述成绝对安全。
- [x] 3.5 移除或替换原“右侧盾牌图标可用于切换连接协议”提示，避免与新三段式控件重复。

## 4. 协议选择弹窗

- [x] 4.1 点击 protocol button 后使用现有 `showPlatformDialog` 打开居中协议选择弹窗。
- [x] 4.2 弹窗列出 `HTTPS` 和 `HTTP`，并标记当前选中协议。
- [x] 4.3 `HTTP` 选项 MUST 展示未加密风险说明；用户确认后才切换到 HTTP。
- [x] 4.4 保留 HTTPS handshake failure dialog 的 “Use HTTP and try again” fallback，并确保 fallback 后三段式 UI 同步为 HTTP / 未加密。

## 5. 本地化

- [x] 5.1 在 `strings*.i18n.yaml` 增加协议选择标题、HTTPS 说明、HTTP 风险说明、使用所选协议、加密、未加密等文案。
- [x] 5.2 运行项目既有 i18n 生成流程，更新 `strings.g.dart`。
- [x] 5.3 确认中文文案通过 UTF-8 安全路径写入，避免 mojibake。

## 6. 测试与验证

- [x] 6.1 新增或更新 focused helper tests，覆盖 `localhost：5230`、`http：//localhost：5230`、`https://memos.example.com/api/v1` 等输入归一化和 compose/parse 结果。
- [x] 6.2 更新 `login_screen_lifecycle_test.dart` 或等价 widget tests，覆盖协议按钮打开弹窗、取消保持 HTTPS、确认 HTTP 后登录使用 `http` scheme。
- [x] 6.3 更新 widget tests，覆盖中文冒号输入后 controller / draft / submitted base URL 均使用英文冒号。
- [x] 6.4 更新 handshake failure tests，确认 fallback 到 HTTP 后三段式 UI 显示 `HTTP` 和未加密状态。
- [x] 6.5 从 `memos_flutter_app` 运行 focused tests：auth login screen tests 和 helper tests。
- [x] 6.6 从 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 6.7 从 `memos_flutter_app` 运行 `flutter test`；如环境或既有失败阻塞，记录具体命令、失败用例和剩余风险。已运行 `flutter test`，剩余失败位于 `test/private_hooks/app_ready_hook_test.dart`、`test/features/home/home_bottom_nav_shell_test.dart` 的两个 about/back 用例，以及 `test/features/onboarding/platform_adaptive_onboarding_test.dart` 的 mobile action width 用例；focused auth tests 与 `flutter analyze` 已通过。
