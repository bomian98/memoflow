## 1. Scope and UX Rules

- [x] 1.1 确认 centered reader 的默认尺寸、最大阅读宽度、边距、header controls 和背景 modal barrier 行为。
- [x] 1.2 确认 fullscreen reader 的 Esc/restore/close 行为，是否与 desktop editor fullscreen 保持一致。
- [x] 1.3 确认 preview pane 是否新增显式 open/fullscreen action，或第一阶段只支持 double click / Enter。
- [x] 1.4 确认 reader 中 edit action 的优先级：replace reader with editor，或 close reader then open editor。
- [x] 1.5 确认 desktop expanded 非 wide 布局的 single click 是否保持旧 detail route/fallback，还是一并改成 preview-first。

## 2. Desktop Reader Intent and State

- [x] 2.1 定义 focused desktop memo reader opening seam，支持 open existing memo、memo uid、或 preview session resolved memo。
- [x] 2.2 将 `MemosListScreen` 中 `_openMemoDetailRoute` 的 desktop wide/open-reader 入口收敛到 reader intent，保留 mobile/narrow fallback。
- [x] 2.3 定义 reader centered/fullscreen surface mode，并明确与 existing editor surface mode 的互斥/优先级。
- [x] 2.4 确保 reader 打开/关闭不清空 preview selection，不误清 inline compose draft，也不干扰 existing editor draft。

## 3. Reader Surface UI

- [x] 3.1 实现 desktop centered reader surface，复用现有 `MemoDocumentBody` / `MemoDocumentPrimaryContent` 渲染。
- [x] 3.2 实现 desktop fullscreen reader surface，使用同一 reader target/state，不 push `MemoDetailScreen` route。
- [x] 3.3 为 reader header 提供 close、fullscreen/restore、edit、more actions，并保持 read-only 查看语义。
- [x] 3.4 Reader 中 edit action 委托到 unified desktop editor intent，不直接 push `MemoEditorScreen`。
- [x] 3.5 处理 preview pane audio 与 reader audio 的 owner 冲突，避免同一 memo/attachment 出现两个并行 playback owners。

## 4. Entry Points

- [x] 4.1 将 desktop preview layout 下 memo card double tap 改为打开 desktop reader surface，而不是旧 full detail route。
- [x] 4.2 将 desktop selected memo 的 Enter/open-detail shortcut 改为打开 desktop reader surface。
- [x] 4.3 如确认新增 preview action，将 preview pane open/fullscreen button 接入 reader intent。
- [x] 4.4 保留 `Cmd/Ctrl+E`、preview edit button、card edit action、detail edit fallback 对 unified desktop editor intent 的委托。
- [x] 4.5 保留 mobile、tablet bottom navigation、desktop narrow 的既有 detail route/fallback 行为，除非需要 chrome safe-area 修复。

## 5. macOS Chrome Safety

- [x] 5.1 确保 centered reader controls 和 content 不与 macOS titlebar / traffic lights 重叠。
- [x] 5.2 确保 fullscreen reader controls 和 content 不与 macOS titlebar / traffic lights 重叠。
- [x] 5.3 修复旧 `MemoDetailScreen` fallback route 的 macOS chrome safe-area，使 remaining fallback 也不会撞系统关闭按钮。
- [x] 5.4 增加或收紧 guardrail，要求 memo reader fallback 使用 shared desktop chrome safe-area seam，不硬编码 traffic-light padding。

## 6. Tests and Guardrails

- [x] 6.1 增加 focused test：desktop wide memo card double tap 打开 reader surface，且不出现旧 `MemoDetailScreen` route。
- [x] 6.2 增加 focused test：desktop wide selected memo Enter 打开 reader surface，且不出现旧 `MemoDetailScreen` route。
- [x] 6.3 增加 focused test：preview pane open/fullscreen action（若实现）打开同一 reader surface。
- [x] 6.4 增加 focused test：reader fullscreen toggle 保留 selected memo、scroll/read state，并可恢复 centered reader。
- [x] 6.5 增加 focused test：reader edit action opens unified desktop editor surface and closes/replaces reader per chosen rule。
- [x] 6.6 增加 fallback tests：mobile/narrow detail route behavior 保持不变。
- [x] 6.7 增加 macOS widget test：centered/fullscreen reader 和 fallback detail route 避开 native titlebar/traffic lights。
- [x] 6.8 增加或收紧 architecture guardrail：desktop reader opening policy 不散落在 lower layers，不新增 `state/application/core -> features` reverse dependencies。

## 7. Verification

- [x] 7.1 运行相关 focused widget/unit tests。
- [x] 7.2 运行相关 architecture guardrails。
- [x] 7.3 在 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 7.4 在 `memos_flutter_app` 运行 `flutter test`；如果完整测试不可行，记录 scoped verification 和剩余风险。

## Verification Notes

- 已通过 focused widget/unit tests：`flutter test test/features/memos/memos_list_screen_test.dart --reporter expanded`、`flutter test test/features/memos/memos_list_screen_test.dart --plain-name "reader" --reporter expanded`、`flutter test test/features/memos/memo_detail_screen_test.dart --reporter expanded`。
- 已通过 architecture guardrails：`flutter test test/architecture/desktop_memo_reader_surface_guardrail_test.dart --reporter expanded`、`flutter test test/architecture/desktop_window_chrome_safe_area_guardrail_test.dart --reporter expanded`。
- 已通过 `flutter analyze`。
- 已尝试运行完整 `flutter test --reporter expanded`，240 秒超时；超时前日志未出现 failure marker，停在约 `+1870 ~1`，主要仍在 compression pipeline tests。剩余风险：完整测试套件未在本轮完成收敛，只能以 scoped verification 覆盖本 change 的 reader、fallback chrome 和 architecture guardrails。
