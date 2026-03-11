# antarx-dev-skills

面向个人开发流程的 skills 仓库。

本仓库目标：
- 在 `skills/` 下沉淀可复用的开发技能
- 通过 Codex 原生 skills 发现机制进行加载
- 维护最小但清晰的工程结构，便于长期迭代
- 作为 skills 与 `AGENTS.md.root` 的单一事实源（SSOT）

## 目录结构

- `.codex/`：Codex 安装与接入说明
- `skills/`：技能定义（核心）
- `scripts/`：本地同步与校验脚本
- `AGENTS.md.root`：统一代理行为配置（受管）
- `docs/`：设计文档与计划
- `commands/`：可选的命令模板
- `agents/`：可选的 agent 指令模板
- `hooks/`：可选的 hook 配置
- `lib/`：工具脚本与公共逻辑
- `tests/`：测试与验证用例

## 快速开始（Codex）

请先阅读：`./.codex/INSTALL.md`

## 双机同步 SOP（台式机/笔记本）

### 1. 一次性准备

```bash
git clone <your-repo-url> ~/code/vibeProjects/antarx-dev-skills
cd ~/code/vibeProjects/antarx-dev-skills
```

### 2. 同步到本机 Codex

先预览：

```bash
./scripts/sync_to_local.sh --dry-run
```

再执行：

```bash
./scripts/sync_to_local.sh
```

说明：
- 默认同步 `skills/` 到 `~/.codex/skills`
- 默认同步 `AGENTS.md.root` 到 `~/.codex/AGENTS.md.root`
- 可通过环境变量覆盖目标路径：

```bash
CODEX_SKILLS_DIR=/custom/skills CODEX_AGENTS_FILE=/custom/AGENTS.md.root ./scripts/sync_to_local.sh
```

### 3. 一致性校验

```bash
./scripts/doctor.sh
```

### 4. 在笔记本新增/编辑 skill 如何同步

统一流程（任意设备都一样）：

1. 在仓库内编辑 `skills/` 或 `AGENTS.md.root`
2. 提交并推送到远端
3. 另一台设备 `git pull`
4. 运行 `./scripts/sync_to_local.sh`
5. 运行 `./scripts/doctor.sh`

注意：
- 不直接手工修改 `~/.codex/skills` 中受管技能。
- 系统技能与 Apple 平台相关技能默认不纳入受管范围：
  - `skill-creator`
  - `skill-installer`
  - `swiftui-macos-llm-chat-module`
