# FourthInspectorPanelUI_20260308

## Related Design Doc
- `/Users/yat/code/xcodeProjects/ArxivDailyReader/docs/design-docs/FourthInspectorPanelUI_20260308.md`

## Phase

### Phase 1: Inspector 基础容器落地

## Tasks

1. [Task#1] 建立 inspector 顶层状态与挂载路径（状态：Designed）
- 任务功能：在 `ContentView` 中引入第四栏基础状态，并将 inspector 挂载到 detail 路径。
- 实现要点：
  - 新增 `isInspectorPresented` 与 `selectedInspectorPanel`。
  - 保持现有 `NavigationSplitView` 三栏结构不变。
  - 显式配置 inspector 列宽约束。
- 预期测试结果：编译通过；点击控制入口后，右侧第四栏可显示与隐藏。

2. [Task#2] 新增 inspector 容器与 panel 切换条（状态：Designed）
- 任务功能：建立 `PaperInspectorView` 及其顶部仅图标 segmented picker。
- 实现要点：
  - 定义 `PaperInspectorPanel` 枚举。
  - 使用 `Picker + .segmented` 切换 `notes` / `chat`。
  - 保持固定骨架，仅切换内容区域。
- 预期测试结果：切换不同 panel 时结构稳定，选中态正确。

3. [Task#3] 接入 detail toolbar 的 inspector toggle（状态：Designed）
- 任务功能：在 `PaperDetailView` macOS toolbar 中加入第四栏显示控制按钮。
- 实现要点：
  - 保持现有 toolbar 分组与主视觉不做额外收缩。
  - 新按钮提供本地化 `help`、`accessibilityLabel`、`accessibilityIdentifier`。
  - 通过回调或 binding 与 `ContentView` 状态联动。
- 预期测试结果：detail 现有工具栏行为不回归；新增按钮能稳定切换第四栏。

4. [Task#4] 保持 detail 底部 TagEditorBar 布局边界（状态：Designed）
- 任务功能：验证 inspector 接入后，底部 `TagEditorBar` 仍只跟随 detail 宽度。
- 实现要点：
  - inspector 不侵入 `PaperDetailView.safeAreaInset(edge: .bottom)`。
  - 检查展开/收起 inspector 时 detail 区和 tag bar 的宽度联动是否正确。
- 预期测试结果：TagEditorBar 不延展到 inspector 下方，空态/内容态均稳定。

5. [Task#5] 最小化本地化与编译验证（状态：Designed）
- 任务功能：补齐本次 UI 基建所需的最小 i18n 资源并执行 macOS 构建。
- 实现要点：
  - 新增 inspector 相关 String Catalog key。
  - 执行 macOS arm64 Debug 构建。
  - 若发生编译失败，先查阅 `build_failure_playbook.md` 再修复，并在通过后追加英文记录。
- 预期测试结果：构建通过，无新增硬编码用户文案。

### Phase 2: Panel 骨架与后续接线预留

6. [Task#6] 建立 Notes panel 占位骨架（状态：Designed）
- 任务功能：为后续论文级 note 接线提供稳定的 inspector 子视图壳层。
- 实现要点：
  - 新增 `PaperInspectorNotesPanel`。
  - 提供列表区、输入区或占位区的基本版式，但不接入真实数据。
  - 预留当前论文上下文入参。
- 预期测试结果：切换到 Notes panel 时显示稳定占位 UI，无数据链路依赖。

7. [Task#7] 建立 Chat panel 占位骨架（状态：Designed）
- 任务功能：为后续基于 arXiv HTML 正文上下文的 LLM 对话接线提供稳定壳层。
- 实现要点：
  - 新增 `PaperInspectorChatPanel`。
  - 预留消息区、输入区、上下文提示区。
  - 明确当前阶段不嵌入 HTML 页面 UI，不接入网络与 LLM。
- 预期测试结果：切换到 Chat panel 时显示稳定占位 UI，结构满足后续扩展。

8. [Task#8] 回归验证与计划回写（状态：Designed）
- 任务功能：完成第四栏 UI 基建后的增量验证，并回写计划状态。
- 实现要点：
  - 进行 macOS 主窗口手工回归检查。
  - 将任务按 `Designed -> Coding -> Testing -> Finished` 更新。
  - 若发现超出本次范围的需求，记录到后续计划而非在本次扩张实现。
- 预期测试结果：第四栏 UI 基建完成，且 Notes/Chat 具体功能仍保持在后续任务范围。
