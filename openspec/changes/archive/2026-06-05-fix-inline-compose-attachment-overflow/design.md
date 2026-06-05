## Context

当前桌面首页 resizable inline compose 的高度模型大致是：

```text
panelHeight = chromeHeight + editorHeight
```

其中 `editorHeight` 由 `homeInlineComposePanelLayout.editorHeight` 持久化，`chromeHeight` 由 `MemosListInlineComposeCard` 报告的 `totalHeight - editorViewportHeight` 反推。这个模型在无附件时可工作；但在 resizable shell 中，card 被 `Positioned(... height: rect.height)` 给了 tight height。添加附件后 `_InlineAttachmentPreview` 会在 editor 上方增加约 `62 + 10 = 72px`，子 Column 已经溢出，而 `MeasureSize` 看到的 total height 仍可能是父级 tight height，不一定能反映真实 chrome 需求。

截图中的 `BOTTOM OVERFLOWED BY 70 PIXELS` 和附件预览高度吻合，说明问题核心是 editor 外 chrome 动态高度没有进入父级 panel 高度预算。

## Goals / Non-Goals

**Goals:**

- 添加 pending attachment 后，桌面首页 resizable inline compose 面板不出现 bottom overflow。
- 保持 `editorHeight` 的语义：用户拖拽保存的是 editor viewport height，不是 panel 总高度。
- 让 attachment preview、linked memo、location、toolbar 等 editor 外内容变化可以稳定更新 chrome height。
- 增加 focused tests，覆盖受控 `desktopEditorViewportHeight` 与 pending attachments 共存的布局路径。
- 保持现有分层边界，不新增 lower layer 对 `features/memos` 的依赖。

**Non-Goals:**

- 不重做 inline compose 的视觉设计、工具栏配置系统或附件预览样式。
- 不修改文件选择、附件 staging、压缩、上传、API payload、数据库或同步行为。
- 不改变移动端 `NoteInputSheet`、全屏 compose 或普通非 resizable inline compose 的布局语义。
- 不改变 `homeInlineComposePanelLayout` 的存储 schema，除非实现中发现无法避免；当前预期不需要迁移。

## Decisions

### Decision 1: 保持 editor height 持久化语义，动态 chrome height 只影响 panel 总高度

`homeInlineComposePanelLayout.editorHeight` 继续表示 editor viewport height。父级 layout 在构造 `DesktopResizablePanelRect.height` 时使用最新 chrome height 加 editor height。这样添加附件时面板整体增高，用户调整过的写作区域不会突然变小。

替代方案是保持 panel 总高度不变，让附件预览挤占 editor 高度。这个方案会避免面板跳变，但会破坏当前 preference 字段语义，并让用户刚保存的 editor height 在附件出现时失真。

### Decision 2: 让 inline compose card 显式报告 chrome 需求，而不是依赖 tight layout 后的 total height

实现应优先在 `MemosListInlineComposeCard` 内建立更明确的 metrics contract，例如报告：

- `editorViewportHeight`
- `chromeHeight`
- `totalDesiredHeight`
- 可选的 `hasDynamicChrome` 或内容 signature

`memos_list_screen.dart` 根据这些 metrics 更新 `_homeInlinePanelChromeHeight`。如果保留现有 `InlineComposeLayoutMetrics` 类型，也应让其 total/chrome 值来自不受父级 tight height 截断的测量或显式计算。

替代方案是用 `IntrinsicHeight` 或外层 `SingleChildScrollView` 包住 card。前者可能增加 layout 成本，后者会把问题变成内部滚动并影响工具栏稳定性，不适合作为主路径。

### Decision 3: 父级更新 chrome height 时保持面板位置和 viewport anchor

附件出现会增加 panel height。父级应复用现有 `_buildHomeInlinePanelRect`、ratio clamp 和 viewport anchor 逻辑，确保：

- 面板不会超出当前 available height。
- 如果可用空间不足，top/yRatio 按现有规则 clamp。
- 用户的 `editorHeight` 不因 chrome 变化被错误持久化。
- resize drag 结束后仍只持久化 width、editorHeight、xRatio、yRatio。

### Decision 4: 通过 focused tests 作为耦合区 guardrail

本 change 不需要新增跨层 seam，但触及 `features/memos` 的复杂桌面 UI。guardrail 应覆盖真实失败组合：

- `MemosListInlineComposeCard` 在 `desktopEditorViewportHeight` 下添加 pending attachment 后 metrics 反映新增 chrome height。
- `MemosListScreen` 在 Windows desktop + saved inline layout + pending attachment 后，`DesktopResizablePanelShell.rect.height` 可容纳 editor 和附件 chrome，且 `tester.takeException()` 不捕获 overflow。
- 删除附件后高度回落或至少不保持错误溢出状态。

依赖方向保持：

```text
features/memos -> application/desktop shell
features/memos -> state/memos controller/state
application/desktop shell -X-> features/memos
state/core/application -X-> features/memos new imports
```

## Risks / Trade-offs

- [Risk] 添加附件后面板整体增高可能使面板底部靠近 memo 列表内容或窗口边界。→ Mitigation: 复用现有 bounds clamp 和 viewport anchor 逻辑，必要时在 available height 内调整 yRatio/top。
- [Risk] metrics 变化触发 setState 过于频繁，导致布局抖动。→ Mitigation: 保留 0.5px 阈值和内容 signature，只有 chrome/editor 高度实际变化时更新。
- [Risk] 测试通过但真实图片/视频 tile 加载后高度再次变化。→ Mitigation: 附件 tile 外框尺寸固定为 62px，测试覆盖 fallback image/video tile 即可锁定布局高度。
- [Risk] 为了快速修复把高度常量散落在父级。→ Mitigation: 高度知识应集中在 inline compose card 或 shared metrics seam，父级只消费 metrics，不复制附件 tile 视觉常量。
