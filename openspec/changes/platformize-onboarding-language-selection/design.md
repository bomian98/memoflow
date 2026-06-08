## Context

`LanguageSelectionScreen` 运行在 `MainHomePage` 的 onboarding 分支中。顶层 `MaterialApp` 已存在，但 iPhone/iPadOS 上 `PlatformPage` 会渲染 `CupertinoPageScaffold`，它不是 `Material` surface。当前页面在该 Cupertino page 内容内直接使用 `DropdownButton<AppLanguage>`，因此首次 setup 到语言选择控件时会触发 `No Material widget found`。

项目已有 `showPlatformPicker` / `showPlatformPopoverOrSheet` seam，settings 偏好页也已经使用该 seam 处理 enum 选择。本变更应让 onboarding 复用同一平台选择模式，而不是在页面本地补一个仅用于压住异常的 `Material` ancestor。

依赖方向保持为：

```text
features/onboarding
  └── imports platform/widgets/platform_picker.dart

platform/widgets
  └── no imports from features/state/application/data
```

这符合 `evolve_modularity` 阶段的要求： touched area 通过复用平台 seam 减少页面本地 platform/material 假设，不新增 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖。

## Goals / Non-Goals

**Goals:**

- 让 iOS 首次 onboarding 语言选择页不再因 `DropdownButton` 缺少 `Material` ancestor 而崩溃。
- 用现有平台 picker seam 呈现语言 enum 选择，使 iPhone/iPadOS、Android 和桌面分别获得合适的 transient surface。
- 保持 `AppLanguage` 选项、选中显示、`devicePreferencesProvider` 写入、onboarding mode 选择和 primary action 行为不变。
- 增加 iOS widget 测试覆盖，验证页面可渲染并能打开语言 picker。

**Non-Goals:**

- 不重新设计完整 onboarding flow。
- 不修改 session、local library 创建、login 路由、startup coordinator 或 legal consent gate。
- 不新增平台 picker framework，也不改变 `showPlatformPicker` 的全局行为。
- 不触碰 API adapter、request/response model、版本兼容逻辑或 `test/data/api`。

## Decisions

### Decision: 用 `showPlatformPicker` 替代 onboarding 内嵌 `DropdownButton`

语言选择属于 enum/single-option selection，项目已有 `showPlatformPicker` 作为语义 seam。实现阶段应把当前 dropdown 替换为一个可点击 selector row/card，点击后调用 `showPlatformPicker` 展示语言列表。

Alternatives considered:

- 仅包 `Material(type: MaterialType.transparency)`：改动最小，但仍保留 iOS 上 Material dropdown 交互，且没有把 enum selection 迁移到平台 seam。
- 把 `PlatformPage` 的 iOS body 全局包 `Material`：可能掩盖更多混用问题，并改变所有 iOS `PlatformPage` 内容的 surface 假设，影响范围过大。
- 自建 Cupertino picker：会复制现有 `showPlatformPicker` 的职责，使 onboarding 成为新的平台分支点。

### Decision: onboarding 语言 picker 使用可选的居中可滚动呈现

语言数量后续可能继续增加，首次 onboarding 又是一个高感知选择场景，因此语言 picker 应使用居中、宽高受限、内部可滚动的 picker surface。实现阶段应把该形态作为 `showPlatformPicker` 的可选 presentation，而不是修改所有 picker 的默认行为；settings 等普通 enum picker 继续使用现有 platform default 策略。

Alternatives considered:

- 全局把 iOS `showPlatformPicker` 改为居中：会影响 settings 中大量轻量偏好选择，范围过大。
- 在 `LanguageSelectionScreen` 中直接调用 `showDialog`：能快速达成视觉目标，但绕过平台 picker seam，使 onboarding 再次成为独立平台分支点。
- 继续使用底部 popup：更轻量，但语言增多后可浏览性和首次选择聚焦度都较弱。

### Decision: 保留语言显示逻辑，改变触发控件

`_languageTitle`、`_languageSubtitle`、`_languageOptions` 和 `_handleLanguageChanged` 应继续作为行为来源。selector row 可复用 `_languageLabel` 或拆出轻量 display helper，但不应引入新的语言映射或本地化分支。

Alternatives considered:

- 在 picker 内重新构造语言 label：容易与页面当前显示不一致。
- 把语言选项抽到 `platform/`：会让平台层知道 app domain enum，违反依赖方向。

### Decision: 测试覆盖真实 iOS 入口形态

现有 onboarding 测试覆盖 macOS 桌面按钮宽度，但没有覆盖 iOS `PlatformPage` 的 Cupertino 分支。实现阶段应新增或扩展 widget test，设置 `debugPlatformTargetOverride = TargetPlatform.iOS` 和手机 viewport，pump `LanguageSelectionScreen`，断言无异常、语言 selector 可点击、picker 内容出现。

Alternatives considered:

- 只跑现有桌面测试：无法覆盖这次实际异常路径。
- 只断言没有 `DropdownButton`：过度绑定实现细节，不能证明 picker 交互可用。

## Risks / Trade-offs

- [Risk] 用 picker 替代 dropdown 会改变首次语言选择的点击路径。→ Mitigation: selector row 明确显示当前语言和 chevron，测试覆盖 tap 后居中 picker 和选项出现。
- [Risk] picker 列表中的 `ListTile` 等 Material widget 在 iOS popup 内仍需要 Material surface。→ Mitigation: 复用 `showPlatformPopoverOrSheet`，其 iOS 分支已包 `Material(type: MaterialType.transparency)`。
- [Risk] 页面内 label 和 picker 内 label 可能重复构造后不一致。→ Mitigation: 复用现有 `_languageTitle` / `_languageSubtitle` helper。
- [Risk] 变更触碰 onboarding 这个启动热点。→ Mitigation: 不改启动决策和 provider 写入路径，只替换选择控件，并保留 macOS/desktop 既有布局测试。

## Migration Plan

1. 在 `LanguageSelectionScreen` 中替换语言 dropdown 为 selector row/card。
2. 增加 `_showLanguagePicker` 或同等私有方法，调用 `showPlatformPicker` 并在选择后复用 `_handleLanguageChanged`。
3. 添加 iOS widget test 覆盖首次 setup 语言 picker。
4. 运行 focused onboarding/platform tests，再按需要运行 `flutter analyze` 和 `flutter test`。

Rollback: 如发现平台 picker 行为回归，可在该页面局部回退到透明 `Material` 包裹的旧 dropdown，同时保留 iOS smoke test 作为防线。

## Open Questions

- picker 列表是否需要同时显示 title 和 native subtitle，还是只显示当前页面同样的两行 label？已采用两行 label，以保持信息量一致。
- selector row 的选中态图标使用 `Icons.expand_more` 还是平台 chevron。实现阶段优先沿用现有图标体系，除非现有 platform component 已提供更合适的 chevron seam。
