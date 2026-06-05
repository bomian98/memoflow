## Why

桌面首页可调整大小的 inline compose 面板在添加附件后会出现 Flutter bottom overflow，截图显示溢出约 70px，和附件预览 strip 的新增高度基本一致。当前 resizable panel 保存并恢复的是 `editorHeight`，但附件预览、linked memo、location 等 editor 外 chrome 变化没有被父级高度预算稳定吸收，导致添加文件后输入卡片底部被工具栏区域挤爆。

本 change 聚焦修复附件加入后的渲染溢出，保持用户已调整的编辑器高度语义，并补上自动化 guardrail，防止后续 chrome 高度变化再次绕过桌面 resize 布局预算。

## What Changes

- 桌面首页 resizable inline compose 面板在 pending attachments 出现、移除或变化时 SHALL 重新计算 panel chrome height，并调整 panel 总高度以容纳附件预览。
- `homeInlineComposePanelLayout.editorHeight` 继续表示 editor viewport height；附件预览等 editor 外内容 SHALL 计入 chrome height，而不是挤占或污染已持久化的 editor height。
- 添加文件、图库图片、视频、相机照片、linked memo 或 location 状态变化后，面板 SHALL 保持无 bottom overflow，工具栏和发送按钮 SHALL 保持可见、可操作。
- 实现 SHALL 优先使用 explicit layout metrics/seam 或 intrinsic-safe measurement，避免依赖 tight parent constraints 下的 `totalHeight - editorViewportHeight` 反推出真实 chrome height。
- 增加 focused widget tests / route tests 覆盖受控 desktop editor height + attachment preview 的组合，确认无 overflow、chrome height 更新、resize persistence 语义不变。
- 不修改附件上传、压缩、文件选择、API payload、数据库模型、同步协议、private hooks 或商业逻辑。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `desktop-home-inline-compose-resize`: 增加 resizable inline compose 面板对附件预览和其他 editor 外 chrome 动态高度的稳定布局要求。

## Impact

- Affected code:
  - `memos_flutter_app/lib/features/memos/widgets/memos_list_inline_compose_card.dart`
  - `memos_flutter_app/lib/features/memos/memos_list_screen.dart`
  - 可能涉及 `memos_flutter_app/lib/application/desktop/desktop_resizable_panel_shell.dart`，仅当需要更清晰的 measurement contract；不得引入 `application -> features` 新依赖。
- Affected tests:
  - `memos_flutter_app/test/features/memos/widgets/memos_list_inline_compose_card_test.dart`
  - `memos_flutter_app/test/features/memos/memos_list_inline_compose_card_test.dart`
  - `memos_flutter_app/test/features/memos/memos_list_screen_test.dart`
  - 可能涉及 `memos_flutter_app/test/application/desktop/desktop_resizable_panel_shell_test.dart`
- Architecture phase: `evolve_modularity`.
- Modularity checklist impact:
  - 触及 checklist `8`、`10`：`features/memos` 桌面 inline compose 是耦合 UI 区域，本 change MUST 通过 explicit layout metrics 或 focused guardrail 让 touched area equal or better structured。
  - 不新增 `state -> features`、`application -> features` 或 `core -> state|application|features` 依赖。
  - 不触及 API 相关代码；不需要 API 编辑批准。
