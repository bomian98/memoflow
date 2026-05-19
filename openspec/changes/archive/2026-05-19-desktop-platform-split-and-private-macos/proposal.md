## 为什么

当前仓库主要面向 Android 和 Windows，而 macOS 商业开发需要保持私有，不能合入公开仓库。同时，代码库里已经出现越来越多 Windows 专属的桌面行为，如果不先治理边界，后续桌面能力很容易只能在 macOS 上重复实现，而不是复用共享逻辑。

## 变更内容

- 建立公开主仓库加私有 macOS 商业覆盖仓库的治理规则。
- 定义强制分层模型，将共享业务逻辑、桌面通用逻辑、平台外壳逻辑和私有商业逻辑分开。
- 定义允许的私有接入点，并禁止产品 ID、权益逻辑、StoreKit 逻辑或私有发布自动化泄露到公开仓库。
- 定义分阶段整改工作，确保未来 Windows 桌面能力尽量落在共享层或桌面通用层，而不是直接耦合到 Windows 外壳代码。
- 定义私有 macOS 商业版的目标结构，包括原生 Apple 外壳行为和私有发布流水线。

## 能力

### 新增能力
- `desktop-layering-governance`：用于将代码归类到共享、桌面通用、平台外壳和私有商业层的规则。
- `private-macos-overlay-boundary`：用于保持 macOS 商业代码位于私有仓库，并且只能通过批准的覆盖接入点集成的规则。
- `macos-commercial-edition-governance`：私有 macOS 版本的治理规则，包括原生外壳归属、私有计费归属和发布隔离。

### 修改能力
- 无。

## 影响

- 影响系统：仓库结构、架构治理、桌面功能开发流程、私有仓库策略、macOS 接入计划和未来 CI/CD 隔离。
- 未来整改可能影响的代码区域：`memos_flutter_app/lib/app.dart`、`memos_flutter_app/lib/application/desktop/`、`memos_flutter_app/lib/features/home/desktop/`、`memos_flutter_app/lib/features/memos/`、`memos_flutter_app/lib/private_hooks/`，以及 `windows/` 和未来私有 `macos/` 等平台目录。
- 此变更本身不实现应用行为；它建立后续实现工作必须遵守的治理契约。
