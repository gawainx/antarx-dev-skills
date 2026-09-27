# Codex 安装

技能统一使用官方 CLI 安装和管理：

```bash
npx skills add gawainx/antarx-dev-skills -g -a codex
npx skills list -g -a codex
npx skills update requirement-clarification -g
npx skills remove requirement-clarification -g -a codex
```

安装时选择需要的技能；省略 `-g` 则安装到当前项目。安装后的技能由 CLI 管理，不链接到本仓库源码。

DESIGN 和 AGENTS 属于独立的全局文件配置，需要时参照 [README](../README.md#codex-全局文件) 显式安装。`scripts/sync_to_local.sh` 与 `scripts/doctor.sh` 不安装、更新、卸载或检查技能。
