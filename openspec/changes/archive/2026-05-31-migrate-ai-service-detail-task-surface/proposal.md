## Why

`AiServiceDetailScreen` 仍然以完整 `Scaffold + AppBar` 页面呈现，但它的主要行为是管理一个 AI 服务配置：修改名称、Base URL、API Key、Headers、启用状态、共享代理设置，执行连接检查，保存或删除服务。这类流程在桌面端更像一个有明确边界的配置任务，而不是需要占据完整主窗口的浏览页面。

第一阶段 change `migrate-settings-secondary-task-surfaces` 只迁移快捷方式编辑和 AI 服务新增向导。AI 服务详情页更复杂，包含保存、删除、连接检查、模型管理和代理设置跳转，因此需要单独作为第二阶段处理。

用户已确认：AI 服务详情页可以新增未保存确认弹窗；代理设置入口采用方案 C，即先保持当前打开方式，不在本 change 中迁移 `AiProxySettingsScreen`。

## What Changes

- 为 AI 服务详情页新增统一入口，例如 `openAiServiceDetail(...)`：桌面端使用共享任务表面，移动端保留现有 route 体验。
- 迁移 `AiSettingsScreen` 中打开 AI 服务详情/管理服务的入口，使桌面端不再直接 push `AiServiceDetailScreen`。
- 让 `AiServiceDetailScreen` 支持嵌入 `PlatformSecondaryTaskFrame`，桌面端显示明确标题、关闭/取消和保存操作。
- 为 AI 服务详情页新增未保存修改检测和关闭确认：
  - 没有修改时直接关闭。
  - 有未保存修改时提示用户保存、放弃修改或继续编辑。
- 保持连接检查、删除服务、模型管理和现有持久化语义不变。
- 代理设置入口保持现状，不在本 change 中改成嵌套任务表面。
- 增加 guardrail 或 focused test，防止 AI 服务详情页回退为直接 push 页面级 `Scaffold + AppBar`。

## Capabilities

### Modified Capabilities

- `desktop-secondary-task-surfaces`: 补充 AI 服务详情管理任务的桌面任务表面要求、未保存确认行为，以及代理设置暂不迁移的边界。

## Impact

- Affected app files:
  - `memos_flutter_app/lib/features/settings/ai_service_detail_screen.dart`
  - `memos_flutter_app/lib/features/settings/ai_settings_screen.dart`
  - possible focused tests under `memos_flutter_app/test/features/settings`
  - desktop secondary task surface guardrail tests
- Dependency:
  - This change SHOULD be implemented after or alongside `migrate-settings-secondary-task-surfaces`, because both use the same settings task surface presenter pattern.
- Out of scope:
  - `AiProxySettingsScreen` migration
  - AI service model editor dialog redesign unless required to preserve current embedded model management behavior
  - export/import, reminders, location picker, camera capture
  - API code under `memos_flutter_app/lib/data/api` or `memos_flutter_app/test/data/api`
  - subscription, billing, entitlement, paywall, StoreKit, private overlay, or other commercial behavior
