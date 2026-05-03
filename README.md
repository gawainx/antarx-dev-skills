# antarx-dev-skills

面向个人开发流程的 skills 仓库。

本仓库目标：
- 在 `skills/` 下沉淀可复用的开发技能
- 通过 Codex 原生 skills 发现机制进行加载
- 维护最小但清晰的工程结构，便于长期迭代
- 作为 `skills/` 的单一事实源（SSOT）

## 目录结构

- `.codex/`：Codex 安装与接入说明
- `skills/`：技能定义（核心）
- `scripts/`：本地同步与校验脚本
- `AGENTS.md.root`：全局代理行为模板（默认不自动同步）
- `docs/`：设计文档与计划
- `commands/`：可选的命令模板
- `agents/`：可选的 agent 指令模板
- `hooks/`：可选的 hook 配置
- `lib/`：工具脚本与公共逻辑
- `tests/`：测试与验证用例

## 快速开始

请先阅读：`./.codex/INSTALL.md`

## 跨设备同步方案

### 1. 一次性准备

```bash
git clone <your-repo-url> ~/code/vibeProjects/antarx-dev-skills
cd ~/code/vibeProjects/antarx-dev-skills
```

### 2. 同步到本机 Codex
顺序执行如下脚本：

```bash
# 预览所有技能
./scripts/sync_to_local.sh --dry-run
# 执行同步动作
./scripts/sync_to_local.sh
```

说明：
- 默认同步 `skills/` 到 `~/.codex/skills`
- 默认不同步 `AGENTS.md.root`，避免覆盖 Codex 系统级 `AGENTS.md`
- 可通过环境变量覆盖目标路径：

```bash
CODEX_SKILLS_DIR=/custom/skills ./scripts/sync_to_local.sh
```

如确需同步 AGENTS 模板，必须显式 opt in：

```bash
CODEX_AGENTS_FILE=/custom/AGENTS.md ./scripts/sync_to_local.sh --sync-agents
```

如果目标 AGENTS 文件已存在且内容不同，脚本会拒绝覆盖。确认已备份并接受覆盖风险后，才使用 `--sync-agents --force-agents`。

### 3. 一致性校验

```bash
./scripts/doctor.sh
```

### 4. 跨设备 skill 同步流程

统一流程（任意设备都一样）：

1. 在仓库内编辑 `skills/`
2. 提交并推送到远端
3. 另一台设备 `git pull`
4. 运行 `./scripts/sync_to_local.sh`
5. 运行 `./scripts/doctor.sh`
