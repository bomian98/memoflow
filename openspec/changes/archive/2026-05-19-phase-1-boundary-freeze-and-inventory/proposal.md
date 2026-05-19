## 为什么

在任何桌面重构或私有 macOS 实现开始前，项目现在需要一个纪律明确的第一阶段。当前代码库已经包含批准的私有接入点，也包含大量 Windows 优先的桌面逻辑，因此眼下需要先冻结边界，并产出可靠盘点：哪些是共享代码，哪些是桌面通用，哪些是 Windows 外壳，哪些必须成为私有 macOS 归属。

## 变更内容

- 建立第 1 阶段的边界冻结和架构盘点治理基线。
- 记录公开共享代码、Windows 外壳代码和未来私有 macOS 代码的初始仓库归属图。
- 识别后续必须拆分为桌面通用职责和 Windows 外壳职责的优先 Windows 优先区域。
- 定义在任何第 2 阶段重构或私有 macOS 启动前必须完成的审计产物。

## 能力

### 新增能力
- `phase-1-architecture-inventory`：产出和维护第一轮代码分类盘点的要求。
- `phase-1-boundary-freeze`：在重构工作开始前冻结公开/私有边界的要求。

### 修改能力
- 无。

## 影响

- 影响产物：仓库治理、后续 change 规划、桌面重构排序和私有 macOS 仓库启动前置条件。
- 盘点涉及的代码区域：`memos_flutter_app/lib/app.dart`、`memos_flutter_app/lib/main.dart`、`memos_flutter_app/lib/application/desktop/`、`memos_flutter_app/lib/features/home/desktop/`、`memos_flutter_app/lib/features/settings/`、`memos_flutter_app/lib/features/memos/`、`memos_flutter_app/lib/core/`、`memos_flutter_app/lib/state/system/`、`memos_flutter_app/lib/private_hooks/` 和 `memos_flutter_app/windows/`。
- 本阶段不实现运行时变更；它创建后续实现变更必须遵守的已批准基线和迁移图。
