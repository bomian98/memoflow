# windows-shell-boundary-consolidation Specification

## Purpose
TBD - created by archiving change phase-2-consolidate-windows-shell-boundaries. Update Purpose after archive.
## Requirements
### Requirement: Windows 外壳归属 SHALL 明确收敛
项目 SHALL 将抽取后的 Windows 专属外壳 widget、窗口控制、命令栏、标题栏行为、Windows 专属设置和 Windows 专属 UX 文案保留在明确的 Windows 归属边界内。

#### Scenario: 抽取桌面通用原语后保留 Windows 外壳
- **WHEN** 某项重构从 Windows 优先代码中抽取桌面通用行为
- **THEN** 剩余的 Windows 专属呈现和原生集成必须继续位于明确的 Windows 外壳归属中

### Requirement: 可复用桌面原语 SHALL 与 Windows 呈现分离
项目 SHALL 将可跨桌面复用的布局、状态、快捷键或窗口协调原语与 Windows 专属呈现代码分离。

#### Scenario: 发现可复用原语
- **WHEN** Windows 外壳代码中存在可被 macOS 以相同语义复用的原语
- **THEN** 该原语必须被移动或抽象到桌面通用归属，而不是继续隐藏在 Windows 外壳实现中

