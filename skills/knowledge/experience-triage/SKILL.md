---
name: experience-triage
description: 用于在完成真实任务后，判断经验、坑、约束或流程应沉淀到 Codex 架构的哪一层。触发场景包括“这次学到的规则该写到哪”、“我刚踩了一个坑想沉淀”、“帮我判断该进 AGENTS.md 还是 skill”、“有个新流程不知道放哪”。
---

# 经验分诊

## 目标
帮助用户把一次任务中学到的经验放到正确层级，并输出明确建议：

- 应该放在哪一层。
- 应该写到哪个文件或目录。
- 应该怎么写。
- 是否值得沉淀。

## 第一步：确认经验内容
先让用户用一句话描述想沉淀的内容。描述太泛时，只追问必要信息：

- 这是一条规则、一个流程、一个工具调用方式，还是一个项目约定？
- 它是每次会话都要遵守，还是只在特定场景触发？
- 它只对当前项目有用，还是跨项目通用？
- 它需要执行命令、读取文件、查询接口，还是只约束 Codex 的判断和表达？

## 第二步：按判断树分诊
按顺序判断，第一个命中的问题就是推荐层级。

### Q1：是否必须每次执行，零例外，且不能依赖模型自觉？
是：推荐使用可执行约束或自动化校验。

优先位置：
- 仓库脚本，例如 `scripts/doctor.sh`、`scripts/check_*.sh`。
- CI 或 pre-commit 检查。
- Codex automation，仅在用户明确要定时提醒、监控或稍后跟进时使用。

写法重点：
- 把约束做成可失败的检查。
- 在 `AGENTS.md` 或相关 skill 中只写“何时运行这个检查”。

例子：
```markdown
## 提交前校验
在声称完成前必须运行 `./scripts/doctor.sh`。如果命令失败，先修复失败项，再同步技能或提交变更。
```

反例：
```markdown
请务必认真检查所有技能是否同步。
```

### Q2：是否需要真实执行命令、查询接口或读取外部状态？
是：推荐写成 script、CLI、MCP tool、connector/plugin 工作流，再由 skill 调用。

优先位置：
- 脚本：`scripts/<action>.sh` 或 skill 内的 `skills/<category>/<skill-name>/scripts/<action>.sh`。
- Skill：`skills/<category>/<skill-name>/SKILL.md` 只描述何时调用脚本、如何解释结果。
- Connector/plugin：当任务依赖 GitHub、Notion、Gmail 等外部服务时，优先使用已有 Codex App connector 或插件能力。

例子：
```markdown
## 验证步骤
运行 `scripts/compare_skill_copies.sh <skill-name>` 比较仓库版本和本地安装版本。若存在差异，停止并询问哪一份是权威来源。
```

反例：
```markdown
凭经验判断本地 skill 应该和仓库一致。
```

### Q3：是否只对某个目录、某类文件或某个模块生效？
是：推荐放到项目级或目录级规则文件。

优先位置：
- 当前仓库根目录 `AGENTS.md`。
- 受影响目录下的嵌套 `AGENTS.md`，如果该项目支持目录级指令。
- 项目文档，例如 `docs/` 中的架构、质量、安全或开发约定文档。

写法重点：
- 写清楚适用路径。
- 避免把项目私有约定写进跨项目 skill。

例子：
```markdown
## Skills 仓库约定
只在 `skills/<category>/<skill-name>/SKILL.md` 中维护可复用技能正文；不要手动修改 `~/.codex/skills` 下的托管副本。
```

反例：
```markdown
所有项目都必须用这个仓库的同步脚本。
```

### Q4：是否是多步流程、专题 checklist 或带分支判断的过程？
是：推荐写成新的 Codex skill，或更新已有 skill。

优先位置：
- 新技能：`skills/<category>/<skill-name>/SKILL.md`。
- 既有技能：直接补到对应 `skills/<category>/<skill-name>/SKILL.md`。
- 长模板、脚本、参考资料：放到该 skill 的 `assets/`、`scripts/` 或 `references/`。

写法重点：
- frontmatter 只保留 `name` 和 `description`。
- `description` 只写触发条件，不写执行步骤。
- 正文写可执行流程、红线、输出格式和例子。

例子：
```markdown
---
name: receiving-code-review
description: 在接收代码评审意见并准备落地前使用，尤其适用于评审意见不清晰或技术上可疑时。
---

# 接收代码评审

## 核心原则
先验证评审意见是否成立，再实现修改。
```

反例：
```markdown
description: 这个技能会先读取文件，然后分析评论，再修改代码，最后运行测试。
```

### Q5：是否是每个会话都应该知道的高频默认行为或硬约束？
是：推荐写入全局或项目级 `AGENTS.md`。

优先位置：
- 全局：`~/.codex/AGENTS.md`，适合跨项目默认行为。
- 项目：仓库根目录 `AGENTS.md`，适合当前项目长期约束。
- 本仓库模板：`AGENTS.md.root`，仅在用户明确要求同步全局模板时修改。

写法重点：
- 只放高频、稳定、短小的规则。
- 如果规则超过几段，优先拆成 skill。
- 若文件已经很长，建议保留入口规则，把细节下沉到 skill。

例子：
```markdown
## Git Commit 防火墙
提交信息必须符合 Conventional Commits，且禁止使用空消息、`fix`、`update` 或 `git commit --amend`。
```

反例：
```markdown
每次遇到任何问题都要完整复盘并更新所有相关文档。
```

### Q6：都不匹配时
推荐不沉淀。

适用情况：
- 只对这一次任务有意义。
- 依赖私人偏好，无法转化为稳定规则。
- 只是对某个偶发错误的回忆，没有可复用触发条件。

回复要直接说明不建议沉淀，并给出原因。

## 第三步：输出可写入草稿
根据命中的层级，给出一段可直接写入目标文件的草稿。草稿必须满足：

- 格式正确，例如 YAML frontmatter、Markdown 标题、列表或代码块。
- 有明确触发条件或适用范围。
- 包含至少一个具体例子或反例。
- 不写“请注意”“认真遵守”“尽量考虑”这类空泛表达。

## 第四步：提示上移或下沉
根据经验的复用频率提醒用户调整层级：

- 同一类经验在多个任务、多个 skill 中反复出现：建议从 skill 上移到 `AGENTS.md`。
- `AGENTS.md` 中某条规则变成复杂流程：建议下沉为 skill。
- Skill 中某个步骤需要稳定读取状态或执行校验：建议下沉为 script、MCP tool 或 connector/plugin 工作流。
- 项目规则被误用于跨项目：建议从全局规则移回项目 `AGENTS.md` 或目录级说明。

## 输出格式
```markdown
【分诊结论】<层级>
【推荐位置】<具体文件或目录>
【判断理由】
- <不超过三条理由>
【写作模板】
<可直接写入的 Markdown 或配置草稿>
【后续提醒】
<上移、下沉、同步、验证或不建议沉淀的提醒；没有就写“无”>
```
