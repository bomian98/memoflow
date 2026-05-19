# phase-1-architecture-inventory Specification

## Purpose
TBD - created by archiving change phase-1-boundary-freeze-and-inventory. Update Purpose after archive.
## Requirements
### Requirement: 第 1 阶段 SHALL 产出第一轮归属盘点
第 1 阶段 SHALL 产出桌面相关仓库区域的盘点，并为每个区域分配一个目标状态：现在共享、桌面通用候选、Windows 外壳或私有 macOS 候选。

#### Scenario: 桌面相关区域被盘点
- **WHEN** 某个子系统、目录或文件组参与桌面行为或私有集成规划
- **THEN** 第 1 阶段盘点必须为它分配一个目标状态，并记录任何不确定性备注

### Requirement: 第 1 阶段 SHALL 识别高优先级 Windows 优先热点
第 1 阶段 SHALL 显式识别当前最容易在不重构时导致 macOS 重复劳动的 Windows 优先热点。

#### Scenario: 产出热点列表
- **WHEN** 第 1 阶段盘点产物被汇总
- **THEN** 产物必须包含覆盖运行时编排、窗口、多窗口、外壳 widget、功能页外壳依赖以及 Windows 专属设置或字符串的热点列表

### Requirement: 第 1 阶段 SHALL 定义第 2 阶段重构队列
第 1 阶段 SHALL 把盘点结果转化为一个优先级明确的后续队列，用于桌面通用抽取和 Windows 外壳收敛工作。

#### Scenario: 第 1 阶段被标记为完成
- **WHEN** 团队宣布边界冻结和盘点已经完成
- **THEN** 必须存在第 2 阶段重构队列，用于最高优先级的拆分工作

