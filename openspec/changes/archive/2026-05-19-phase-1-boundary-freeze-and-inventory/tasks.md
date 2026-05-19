## 1. 边界冻结

- [x] 1.1 确认公开仓库在第 1 阶段不会添加 `macos/` 平台脚手架。
- [x] 1.2 确认商业运行时、StoreKit、权益逻辑和 Apple 发布自动化仍然禁止进入公开仓库。
- [x] 1.3 确认 `memos_flutter_app/lib/private_hooks/active_private_extension_bundle.dart` 仍然是第 1 阶段唯一批准的私有 Dart 接入点。

## 2. 盘点产物

- [x] 2.1 产出仓库归属图，覆盖共享代码、桌面通用候选、Windows 外壳区域和私有 macOS 候选。
- [x] 2.2 产出 Windows 优先桌面耦合热点列表，用于驱动第 2 阶段重构。
- [x] 2.3 产出 `application/desktop`、`features/home/desktop`、`private_hooks`、`core`、`state` 和相关功能页面的公开目录目标图。

## 3. 第 2 阶段重构队列

- [x] 3.1 识别哪些桌面运行时行为可能是桌面通用抽取候选。
- [x] 3.2 识别哪些外壳和 UI 行为在抽取后仍应保持 Windows 归属。
- [x] 3.3 为最高优先级的桌面通用和 Windows 外壳拆分工作打开后续实现变更。

## 4. 私有 macOS 就绪门槛

- [x] 4.1 识别私有 macOS 覆盖仓库启动前必须完成的公开仓库前置条件。
- [x] 4.2 识别首批 macOS 私有归属区域：外壳外观、菜单、设置窗口行为、计费、权益和发布工作流。
- [x] 4.3 确认声明第 1 阶段完成并允许第 2 阶段开始的标准。
