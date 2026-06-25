# skills.sh 公开安装实现计划

> **给 Claude：** 必需工作流：使用 superpowers:executing-plans 逐任务实现此计划。

**目标：** 让本仓库可以通过 `npx skills@latest add gawainx/antarx-dev-skills` 作为公开 skill 仓库安装。

**相关设计文档：** 无单独设计文档；本计划直接承接本轮调研结论。

**架构：** 新增 `.claude-plugin/plugin.json` 作为 skills.sh 读取的仓库级清单，继续保留现有 `skills/<category>/<skill-name>/SKILL.md` 源码结构。`scripts/doctor.sh` 增加清单一致性检查，README 同时说明公开安装和维护者本地同步流程。

**技术栈：** Bash、JSON manifest、Markdown。

**范围 / 非范围：** 本次只增加公开安装入口、校验和说明；不重写现有 skill 内容，不移除个人本地同步脚本。

---

## Phase #1: skills.sh 安装入口

### Task #1: 插件清单

**状态：** Finished

**文件：**
- 创建：`.claude-plugin/plugin.json`
- 验证：`scripts/doctor.sh`

- 功能：声明公开可安装的 skill 目录。
- 实现说明：使用 `gawainx/antarx-dev-skills` 对应的仓库清单格式，路径指向现有 `skills/<category>/<skill-name>` 目录。
- 预期验证结果：每个 manifest 路径都存在 `SKILL.md`。

### Task #2: 清单校验

**状态：** Finished

**文件：**
- 修改：`scripts/doctor.sh`
- 验证：`./scripts/doctor.sh`

- 功能：在本地 doctor 中校验 `.claude-plugin/plugin.json` 的路径、重复项和 blacklist。
- 实现说明：用 Bash 调用系统 Python JSON parser，避免引入 jq 依赖。
- 预期验证结果：doctor 能发现 manifest 缺失路径、重复路径和黑名单 skill。

### Task #3: README 安装说明

**状态：** Finished

**文件：**
- 修改：`README.md`

- 功能：把公开安装命令放到快速开始，并保留维护者本地同步流程。
- 实现说明：说明 `.claude-plugin/plugin.json` 只是 skills.sh 的发布清单，安装时仍可选择 Codex。
- 预期验证结果：README 中包含 `npx skills@latest add gawainx/antarx-dev-skills`。
