## ADDED Requirements

### Requirement: Content fallback extraction uses strict tag zones
当后端 tag payload 缺失、为空、陈旧，或本地-only memo 内容需要从正文推导标签时，app MUST 只从严格标签区提取标签。严格标签区仅包含 memo 的首个和最后一个非空内容行；候选行 trim 后 MUST 以一个或多个空白分隔的 `#tag` token 开头。tag prefix 后 MAY 跟随普通说明文字，但说明文字中的后续 `#...` MUST NOT 被提取为标签。普通正文中夹带的 `#...` MUST NOT 被提取为标签。

#### Scenario: First and last tag-zone lines are extracted
- **WHEN** memo content has first non-empty line `#openwrt #build`, middle body text, and last non-empty line `#router`
- **THEN** fallback extraction MUST return `openwrt`, `build`, and `router`
- **AND** local tag storage, search, and statistics MUST reflect only those extracted tag paths when no backend tag payload is available

#### Scenario: Leading tag prefix with trailing prose is extracted
- **WHEN** memo content has first or last non-empty line `#测试文本 测试文本`
- **THEN** fallback extraction MUST return `测试文本`
- **AND** the trailing prose `测试文本` MUST remain normal memo content

#### Scenario: Later prose hash after tag prefix is ignored
- **WHEN** memo content has first or last non-empty line `#first text #ignored`
- **THEN** fallback extraction MUST return `first`
- **AND** fallback extraction MUST NOT include `ignored`

#### Scenario: Body prose hash is ignored
- **WHEN** memo content contains ordinary prose such as `测试文本 #这是测试文本`
- **THEN** fallback extraction MUST NOT create `这是测试文本` as a tag
- **AND** the prose content MUST remain unchanged

#### Scenario: Middle body tag is ignored
- **WHEN** memo content has a valid-looking `#middle-tag` only in a middle paragraph, list item, blockquote, or table cell
- **THEN** fallback extraction MUST NOT include `middle-tag`

#### Scenario: Non-zone first or last line is ignored
- **WHEN** the first or last non-empty line contains prose plus a hash fragment such as `今天记录一下 #生活`
- **THEN** fallback extraction MUST NOT include `生活`

#### Scenario: Protected Markdown contexts remain ignored
- **WHEN** memo content contains code blocks, inline code, links, images, or URL fragments with `#...`
- **THEN** fallback extraction MUST NOT create tags from those protected contexts
- **AND** valid tags in strict tag-zone lines outside those protected contexts MUST still be extracted

#### Scenario: Backend tag payload remains authoritative
- **WHEN** remote sync receives a memo with a non-empty backend `Memo.tags` payload
- **THEN** local storage MUST preserve the backend tag payload even if those tags are not present in strict tag-zone lines

### Requirement: Memo tag decoration follows strict tag zones
Memo HTML rendering MUST decorate clickable tag chips only for tags that are in strict tag-zone lines. Display decoration MUST NOT make ordinary prose hash fragments look like persisted or navigable tags.

#### Scenario: Prose hash is not decorated
- **WHEN** memo content contains `测试文本 #这是测试文本`
- **THEN** rendered memo HTML MUST NOT wrap `#这是测试文本` with the memo tag decoration span

#### Scenario: Tag-zone line is decorated
- **WHEN** memo content contains a strict tag-zone prefix such as `#openwrt #build body #ignored`
- **THEN** rendered memo HTML SHOULD decorate `#openwrt` and `#build` as memo tags
- **AND** rendered memo HTML MUST NOT decorate `#ignored`

## REMOVED Requirements

### Requirement: Content fallback extraction covers full memo content
**Reason**: 全正文扫描会把普通正文中的 `#这是测试文本`、shell 注释、说明性片段等误识别为本地标签，造成标签统计、搜索和 UI 展示污染。

**Migration**: 使用新的 `Content fallback extraction uses strict tag zones` 需求。既有 memo 的历史误识别标签不得静默删除；用户需要通过显式 self-repair 或后续编辑触发当前规则重建。
