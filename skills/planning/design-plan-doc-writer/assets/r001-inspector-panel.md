# r001-inspector-panel

本示例展示同一需求文档中的设计与开发计划。需求澄清已完成；示例编号仅用于展示，新需求应按项目已有编号递增。

## 需求澄清

用户需要在 macOS 论文详情右侧增加可显隐的辅助面板，通过工具栏控制显隐，并在 Notes 与 Chat 占位面板间切换。本轮只建立 UI 容器与状态结构；具体笔记、网络和模型调用留待后续需求。验收重点为显隐、切换、空态与详情底部标签栏的布局稳定性。

## 设计文档

### 核心功能

#### 需求背景

当前 macOS 主界面采用三栏 `NavigationSplitView`：
- 左侧为 `MainSidebarView`
- 中间为 `PaperListView`
- 右侧为 `PaperDetailView`

用户希望在主界面右侧增加一个可显隐的第四栏，用于承载当前论文相关的辅助工作流。目标交互参考 Xcode/Apple 官方工作台风格：
1. 通过主工具栏右侧一个按钮控制第四栏出现和消失。
2. 第四栏附着在详情列右侧，不改变左侧导航语义。
3. 第四栏顶部通过仅图标的分段切换条在不同子 panel 之间切换。

结合现有代码结构和 Apple 官方 SwiftUI 能力，本次需求采用 `NavigationSplitView + inspector` 方案落地，而不是将现有主窗口重构为四个真实 split column。

#### 需求目标

本次仅完成“第四栏 UI 基建”，目标如下：
1. 为 macOS 主窗口增加可显隐的右侧 inspector。
2. 在 detail 工具栏中新增 inspector toggle 按钮。
3. 在 inspector 内建立稳定的顶部 panel 切换结构，采用 `Picker + .segmented`，仅显示图标。
4. 建立 inspector 容器、panel 枚举、空态/选中态的 UI 骨架，为后续接入 `Notes` 与 `Chat` 功能提供稳定承载位。
5. 保持现有 `PaperDetailView` 底部 `TagEditorBar` 布局语义不变，其宽度仅跟随 detail 内容，不占用 inspector 宽度。

#### 范围边界

##### 本次范围内

- macOS 主窗口右侧 inspector 容器与显隐状态管理。
- inspector 顶部 panel 切换 UI。
- inspector 空态/占位态与列宽约束。
- detail toolbar 中的 inspector toggle 入口。
- 视图分层与状态模型设计，为后续 panel 接线预留 API。

##### 本次范围外

- `Notes` 面板的数据读取、列表呈现、编辑与新增逻辑。
- 基于 arXiv HTML 版本的正文抓取、抽取、缓存与 LLM 对话能力。
- inspector 内任何业务级网络请求、持久化写入或大模型调用。
- iOS 端对应交互适配。

### 实现流程

#### 1. 现状调研结论

##### 1.1 当前主窗口结构

- `ArxivDailyReader/ContentView.swift`
  - `mainSplitView` 采用 `NavigationSplitView { sidebar } content: { list } detail: { detail }`
  - 现有三列宽度已完成约束，且启用了 `.navigationSplitViewStyle(.balanced)`
- `ArxivDailyReader/Views/PaperDetailView.swift`
  - 详情列已拥有独立 toolbar
  - 底部通过 `safeAreaInset(edge: .bottom)` 挂载 `TagEditorBar`

##### 1.2 Apple 官方能力判断

根据 Apple WWDC23 `Inspectors in SwiftUI`：
1. `inspector` 可直接挂在 `NavigationSplitView` 的 detail 路径上。
2. `inspector` 可通过布尔状态控制显隐。
3. `inspector` 支持独立列宽配置。
4. inspector 内容内部可继续使用系统控件组织工具条和分段切换。

因此，第四栏最合适的实现形态是：
- 主结构仍为三栏 `NavigationSplitView`
- 第四栏使用 `inspector`
- inspector 的 panel 切换条由内容内部使用 `Picker + .segmented` 自行构建

#### 2. 目标结构设计

##### 2.1 顶层容器：`ContentView`

在 `ContentView` 中新增 inspector 基础状态：
- `isInspectorPresented: Bool`
- `selectedInspectorPanel: PaperInspectorPanel`

推荐职责：
1. `ContentView` 作为主窗口容器，拥有 inspector 是否显示的状态。
2. `ContentView` 负责将当前选中的 `PaperSummary?` 传入 inspector 容器。
3. inspector 挂载在 `detail` 路径上，确保其语义严格属于当前论文详情，而不是属于 sidebar 或 list。

目标形态：
- `NavigationSplitView` 三栏保持不变。
- `PaperDetailView(...)`
  - 承载 detail 内容与底部 `TagEditorBar`
  - 暴露 inspector toggle 回调
  - 由外层或 detail 层挂载 `.inspector(isPresented:)`

##### 2.2 inspector 容器：`PaperInspectorView`

新增独立 inspector 容器视图，职责如下：
1. 提供固定顶部 panel 切换区。
2. 根据 `selectedInspectorPanel` 切换内容区域。
3. 在 `paper == nil` 时提供统一空态，而不是让每个业务 panel 自行分叉控制。
4. 对后续 `Notes` 和 `Chat` 提供稳定挂载点。

建议结构：
- 顶部：`Picker(selection:)`
  - `pickerStyle(.segmented)`
  - 仅图标，不展示文字
- 下方：`Group` / `switch selectedInspectorPanel`
  - `paper == nil` 时显示统一空态
  - `paper != nil` 时显示对应 panel 的占位容器

##### 2.3 panel 枚举：`PaperInspectorPanel`

新增一个稳定枚举，用于表达第四栏当前选中的 panel。

首批 case：
- `.notes`
- `.chat`

枚举职责：
1. 作为 `Picker` 的选择值。
2. 统一映射 icon、`accessibilityIdentifier` 与后续本地化标签。
3. 限制 panel 扩展入口，避免直接在视图里散落硬编码分支。

##### 2.4 detail toolbar 集成

在 `PaperDetailView` macOS toolbar 中新增 inspector toggle 按钮：
1. 位置：放在当前 detail toolbar 右侧动作组中，不主动重排既有业务按钮分组。
2. 语义：控制第四栏显隐。
3. 交互：
   - inspector 已显示：再次点击关闭
   - inspector 已关闭：点击打开，并保留上次选中的 panel

说明：
- 用户已明确当前 detail toolbar 视觉并不拥挤，因此本次不以“腾位置”为目标调整现有图标布局。

##### 2.5 `TagEditorBar` 布局约束

当前 `TagEditorBar` 位于 `PaperDetailView` 底部，属于 detail 内容的一部分。

本次硬性保持：
1. `TagEditorBar` 仍然绑定在 detail 列下方。
2. inspector 展开后，`TagEditorBar` 仍与 detail 宽度一致。
3. inspector 不承载 tag 编辑 UI，也不改变 `TagEditorBar` 的 safe area 挂载位置。

这意味着 inspector 必须作为 detail 右侧附加列存在，而不能把 `PaperDetailView` 自身包进 inspector 内容内部。

#### 3. 视图拆分建议

##### 3.1 新增视图文件建议

- `ArxivDailyReader/Views/PaperInspectorView.swift`
  - inspector 容器与顶部 segmented picker
- `ArxivDailyReader/Views/PaperInspectorNotesPanel.swift`
  - Notes panel 占位壳层
- `ArxivDailyReader/Views/PaperInspectorChatPanel.swift`
  - Chat panel 占位壳层

说明：
- 本次阶段允许 `Notes` / `Chat` panel 仅作为占位骨架存在。
- 后续功能会在对应 panel 文件内扩展，不污染 `ContentView` 和 `PaperDetailView`。

##### 3.2 状态与依赖边界

本次 UI 基建阶段仅下发以下最小上下文：
- 当前 `paper: PaperSummary?`
- `selectedPanel`
- inspector 是否显示

禁止在本次阶段引入：
- note repository 读写
- arXiv HTML 拉取
- LLM streaming 状态
- 新的异步任务编排

#### 4. 列宽与布局策略

##### 4.1 inspector 列宽

建议为 inspector 设置独立宽度约束：
- `min`: 280 左右
- `ideal`: 320~360
- `max`: 420 左右

设计原则：
1. `Notes` 面板需要容纳可读列表和输入区域。
2. `Chat` 面板未来需要承载消息流和输入框，不能过窄。
3. 不能挤压 detail 正文阅读区到不可读程度。

最终具体数值可在编码阶段微调，但本次设计上要求“显式设置列宽”，不依赖系统默认值。

##### 4.2 结构稳定性

遵循现有仓库对 macOS 布局稳定性的约束：
1. inspector 容器结构应常驻，通过显隐状态控制，不在高频状态下频繁创建/销毁多层子树。
2. 顶部 panel 切换保持固定骨架，仅切换内容区域。
3. 不在布局路径内触发持久化写入。
4. 若切换 panel 时出现隐式动画抖动，优先在 inspector 层禁用相关动画事务，而不是改变交互语义。

#### 5. 本次阶段与后续功能接线关系

##### 5.1 Notes panel 后续接线预留

后续会在 `Notes` panel 接入：
1. 当前论文 note 列表读取
2. note 新增入口
3. 可能的 note 编辑/删除操作

本次设计要求：
- `PaperInspectorNotesPanel` 的输入形态、滚动容器和工具区域骨架要先稳定下来。
- 但不在本任务中落实真实数据绑定。

##### 5.2 Chat panel 后续接线预留

后续 `Chat` panel 的正确技术方向为：
1. 不直接嵌入 HTML 页面 UI。
2. 以 arXiv HTML 版本抽取后的正文上下文作为 LLM 输入源。
3. panel 主体是对话 UI，而不是 HTML 浏览器。

本次设计要求：
- `PaperInspectorChatPanel` 预留“消息区 + 输入区 + 上下文状态提示”的版式骨架。
- 但不在本任务中接入网络或 LLM。

### i18n

#### 新增 key 清单

预计新增以下命名空间 key：
- `content.inspector.toggle`
- `content.inspector.panel.notes`
- `content.inspector.panel.chat`
- `content.inspector.empty.title`
- `content.inspector.empty.description`
- `content.inspector.notes.placeholder`
- `content.inspector.chat.placeholder`

说明：
- 若编码阶段决定 segmented picker 仅使用图标而不展示文本，仍建议保留对应本地化 key，用于 `help`、`accessibilityLabel` 和空态文案。

#### 占位符说明

- 本次预计无需动态占位符。

#### zh-Hans/en 对照

- `content.inspector.toggle`
  - zh-Hans: 打开或关闭辅助面板
  - en: Toggle Inspector
- `content.inspector.panel.notes`
  - zh-Hans: 笔记
  - en: Notes
- `content.inspector.panel.chat`
  - zh-Hans: 对话
  - en: Chat
- `content.inspector.empty.title`
  - zh-Hans: 未选择论文
  - en: No Paper Selected
- `content.inspector.empty.description`
  - zh-Hans: 选择一篇论文后可查看辅助面板内容。
  - en: Select a paper to view inspector content.
- `content.inspector.notes.placeholder`
  - zh-Hans: 笔记面板将在后续任务接入。
  - en: Notes panel will be connected in a follow-up task.
- `content.inspector.chat.placeholder`
  - zh-Hans: 对话面板将在后续任务接入。
  - en: Chat panel will be connected in a follow-up task.

#### 回退策略与影响范围

1. 所有用户可见文案统一写入 `ArxivDailyReader/Resources/Localizable.xcstrings`。
2. 若某语言缺失，对应控件回退到 catalog 默认语言。
3. 影响范围仅限 macOS 主窗口第四栏 UI，不影响既有 iOS 页面。

### 测试用例

#### 编译验证

1. macOS Debug 构建通过：
   - `xcodebuild -scheme ArxivDailyReader -destination "platform=macOS,arch=arm64" -configuration Debug build`

#### 功能验证（手工）

1. 点击 detail toolbar 中新增按钮，可打开/关闭 inspector。
2. inspector 展开后位于 detail 右侧，且主窗口左三栏语义不变。
3. inspector 顶部显示仅图标 segmented picker。
4. 切换 `Notes` / `Chat` 时，顶部切换区不抖动，内容区正常切换。
5. 未选中论文时，inspector 显示统一空态。
6. inspector 展开时，底部 `TagEditorBar` 仍只占据 detail 区域宽度。

#### 回归验证

1. `PaperDetailView` 现有收藏、翻译、总结、分享等按钮行为不变。
2. `NavigationSplitView` 三栏宽度约束仍然生效。
3. 不新增 render path 持久化写入。
4. 不新增用户可见硬编码文案。

## 开发计划

关联设计：[设计文档](#设计文档)。

### Stage 1: Inspector 基础容器落地

#### 任务 #1: 建立 inspector 顶层状态与挂载路径

**Status:** Designed

**Files:** Modify `ArxivDailyReader/ContentView.swift`

- 任务功能：在 `ContentView` 中引入第四栏基础状态，并将 inspector 挂载到 detail 路径。
- 实现要点：
  - 新增 `isInspectorPresented` 与 `selectedInspectorPanel`。
  - 保持现有 `NavigationSplitView` 三栏结构不变。
  - 显式配置 inspector 列宽约束。
- 预期测试结果：编译通过；点击控制入口后，右侧第四栏可显示与隐藏。

#### 任务 #2: 新增 inspector 容器与 panel 切换条

**Status:** Designed

**Files:** Create `ArxivDailyReader/Views/PaperInspectorView.swift`

- 任务功能：建立 `PaperInspectorView` 及其顶部仅图标 segmented picker。
- 实现要点：
  - 定义 `PaperInspectorPanel` 枚举。
  - 使用 `Picker + .segmented` 切换 `notes` / `chat`。
  - 保持固定骨架，仅切换内容区域。
- 预期测试结果：切换不同 panel 时结构稳定，选中态正确。

#### 任务 #3: 接入 detail toolbar 的 inspector toggle

**Status:** Designed

**Files:** Modify `ArxivDailyReader/Views/PaperDetailView.swift`

- 任务功能：在 `PaperDetailView` macOS toolbar 中加入第四栏显示控制按钮。
- 实现要点：
  - 保持现有 toolbar 分组与主视觉不做额外收缩。
  - 新按钮提供本地化 `help`、`accessibilityLabel`、`accessibilityIdentifier`。
  - 通过回调或 binding 与 `ContentView` 状态联动。
- 预期测试结果：detail 现有工具栏行为不回归；新增按钮能稳定切换第四栏。

#### 任务 #4: 保持 detail 底部 TagEditorBar 布局边界

**Status:** Designed

**Files:** Verify `ArxivDailyReader/Views/PaperDetailView.swift`

- 任务功能：验证 inspector 接入后，底部 `TagEditorBar` 仍只跟随 detail 宽度。
- 实现要点：
  - inspector 不侵入 `PaperDetailView.safeAreaInset(edge: .bottom)`。
  - 检查展开/收起 inspector 时 detail 区和 tag bar 的宽度联动是否正确。
- 预期测试结果：TagEditorBar 不延展到 inspector 下方，空态/内容态均稳定。

#### 任务 #5: 最小化本地化与编译验证

**Status:** Designed

**Files:** Modify `ArxivDailyReader/Resources/Localizable.xcstrings`

- 任务功能：补齐本次 UI 基建所需的最小 i18n 资源并执行 macOS 构建。
- 实现要点：
  - 新增 inspector 相关 String Catalog key。
  - 执行 macOS arm64 Debug 构建。
- 预期测试结果：构建通过，无新增硬编码用户文案。

### Stage 2: Panel 骨架与后续接线预留

#### 任务 #6: 建立 Notes panel 占位骨架

**Status:** Designed

**Files:** Create `ArxivDailyReader/Views/PaperInspectorNotesPanel.swift`

- 任务功能：为后续论文级 note 接线提供稳定的 inspector 子视图壳层。
- 实现要点：
  - 新增 `PaperInspectorNotesPanel`。
  - 提供列表区、输入区或占位区的基本版式，但不接入真实数据。
  - 预留当前论文上下文入参。
- 预期测试结果：切换到 Notes panel 时显示稳定占位 UI，无数据链路依赖。

#### 任务 #7: 建立 Chat panel 占位骨架

**Status:** Designed

**Files:** Create `ArxivDailyReader/Views/PaperInspectorChatPanel.swift`

- 任务功能：为后续基于 arXiv HTML 正文上下文的 LLM 对话接线提供稳定壳层。
- 实现要点：
  - 新增 `PaperInspectorChatPanel`。
  - 预留消息区、输入区、上下文提示区。
  - 明确当前阶段不嵌入 HTML 页面 UI，不接入网络与 LLM。
- 预期测试结果：切换到 Chat panel 时显示稳定占位 UI，结构满足后续扩展。

#### 任务 #8: 回归验证与计划回写

**Status:** Designed

**Files:** Verify `ArxivDailyReader/ContentView.swift`; Modify 当前需求文档的开发计划章节

- 任务功能：完成第四栏 UI 基建后的增量验证，并回写计划状态。
- 实现要点：
  - 进行 macOS 主窗口手工回归检查。
  - 将任务按 `Designed -> Coding -> Testing -> Finished` 更新。
  - 若发现超出本次范围的需求，记录到后续计划而非在本次扩张实现。
- 预期测试结果：第四栏 UI 基建完成，且 Notes/Chat 具体功能仍保持在后续任务范围。
