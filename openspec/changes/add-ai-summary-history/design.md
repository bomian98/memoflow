## Context

`apple-commercialization-capability-boundary` 已经引入产品级 `AppCapability` 和公开能力查询 seam。`AppCapability.aiSummaryHistory` 已经存在，但目前还没有对应的成品历史体验。

现有 AI 总结能力主要集中在 `memos_flutter_app/lib/features/review/ai_summary_screen.dart`、自定义 insight templates 和 AI settings providers。下一步应把成功生成的总结结果沉淀为可查看、可管理、可复用的用户数据，同时让能力判断保持窄而明确。

## Goals / Non-Goals

**Goals:**

- 本地保存已完成的 AI summary / insight 结果。
- 从 AI 总结页面进入历史列表和历史详情。
- 支持复制保存的结果，并在产品规则允许时重新运行相同配置。
- 使用 `AppCapability.aiSummaryHistory` 控制历史额度和受限操作。
- 降级或过期时保留用户数据，不因为能力变化静默删除历史。
- 保持商业状态不进入 public shell 和共享 public models。

**Non-Goals:**

- 不接入 StoreKit 或真实购买。
- 不实现 AI 总结历史云同步。
- 不修改 server API。
- 不扩展为通用 AI task history。
- 不把 paid-feature state 存入共享 public models。

## Decisions

### 1. History 是产品数据，不是商业状态

公开 app 可以保存 AI 总结历史，因为这是用户生成的产品数据。但公开 app 不应保存用户为什么拥有更多或更少历史额度。

允许公开保存的字段应是产品/历史字段，例如：

```text
id
createdAt
templateId
templateTitleSnapshot
sourceScope
sourceFingerprint / sourceDescription
resultMarkdown
modelDisplayNameSnapshot
inputMemoCount
```

禁止公开保存的字段包括：

```text
plan
subscriptionState
buyoutState
entitlementState
productId
price
receipt
StoreKit transaction data
```

### 2. Capability 控制行为，不控制数据身份

功能代码应查询：

```text
appCapabilityEnabledProvider(AppCapability.aiSummaryHistory)
```

然后把这个产品级能力决策转换成历史额度、浏览额度、复制权限或 rerun 权限等产品行为。

公开功能不得根据 `trial`、`subscriptionPro`、`buyoutPro`、`expired`、`refunded` 等原始商业状态分支。

### 3. 降级只限制行为，不销毁数据

当 `AppCapability.aiSummaryHistory` 不可用时，历史记录不应被自动删除。降级用户可能已有超过当前额度的历史。

保守规则如下：

```text
enabled capability:
  使用完整历史额度和完整历史操作

default/free capability:
  保留并开放 Free 基线额度

downgraded/expired capability:
  历史记录继续保存在本地
  当前额度决定哪些记录可复制或 rerun
  删除始终可用，用户可以管理自己的数据
```

如果 UX 需要区分“从未付费的 Free 用户”和“过期后保留较多历史的用户”，也不能在公开代码中读取原始 entitlement state；只能依赖产品数据形态或产品级 capability decision。

### 4. 持久化 owner 不应是 screen

`ai_summary_screen.dart` 已经偏大。AI 总结历史的持久化应由 repository / provider / service 等稳定 seam 负责，避免把数据库表结构、序列化和迁移逻辑继续塞进 screen。

期望依赖方向：

```text
features/review UI
  -> state/provider or application service
    -> data repository / local database
      -> core/db primitives

features/review UI
  -> access_boundary capability provider
```

应避免：

```text
ai_summary_screen.dart owns table schema or direct SQL
state/application imports features screens
shared models store commercial plan state
```

### 5. 历史记录需要快照关键展示信息

模板可能在总结生成后被重命名、编辑、隐藏或删除。历史记录应保存足够的快照信息，保证旧记录仍然可读：

- 生成时的模板标题
- 模板类型或 custom template id
- 来源范围 label / fingerprint
- 生成时间
- 总结结果内容
- 可选的 model display name

这样可以避免模板变化后旧历史失去上下文。

## Risks / Trade-offs

- [Database shape churn] 后续可能需要同步或导出。缓解：本地 model 明确表达历史数据，不把当前页面状态原样持久化。
- [Screen grows larger] AI 总结页面已经是热点文件。缓解：把持久化和 access rules 放到 focused helpers/providers。
- [Ambiguous downgrade UX] 用户会认为历史结果属于自己。缓解：不自动删除；只限制超额记录的主动操作。
- [Commercial leakage] 很容易写出 “Pro history” 之类的模型。缓解：公开代码只使用 `AppCapability.aiSummaryHistory` 和产品额度。
- [Privacy] AI 总结结果可能包含敏感 memo 内容。缓解：本 change 只做本地保存，并提供删除能力。

## Open Questions

- Free 基线历史额度到底是最近 5 条、最近 10 条，还是按时间窗口限制？
- 能力不可用时，超额记录应完整可查看但不可复制/rerun，还是只显示占位并保持可删除？
- 第一版是否需要搜索/筛选，还是只做按时间倒序浏览？
- rerun 应使用原始 memo set 快照、当前匹配的 source scope，还是只重新打开模板/范围控制？
