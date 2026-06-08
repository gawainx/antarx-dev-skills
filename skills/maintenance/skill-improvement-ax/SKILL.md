---
name: skill-improvement-ax
description: 当 Codex 需要从任意项目会话中捕获、改进或回填可复用工作流知识到 antarx-dev-skills 仓库时使用。触发场景包括“沉淀技能”“改良技能”“同步回技能仓库”“把这个流程做成 skill”，或更新现有 Codex skill，并更新本地链接安装、打开 GitHub PR。
---

# 技能改进 AX

使用这个技能，在不切换会话的情况下，基于当前项目上下文改进托管的 Codex skills。

## 必须顺序

1. 在写入任何内容前先澄清需求。
2. 将可复用的工作流知识与项目特定信息分离。
3. 使用 `scripts/resolve_source_repo.sh` 解析源仓库。
4. 检查源仓库中的目标 skill 和本地安装链接。
5. 说明计划修改的补丁范围，并获得用户确认。
6. 先编辑源仓库。
7. 运行源仓库验证和 `scripts/sync_to_local.sh`。
8. 创建非受保护分支，commit、push，并使用 `gh` 打开 PR。

## 保护规则

- 不要把当前项目的业务内容、私有路径、客户数据、密钥或内部实现细节写入 skill。
- 现有 skills 必须通过补丁原地更新。不要覆盖或重新创建已有的 skill 目录。
- 如果本地安装链接缺失或没有指向源仓库，先修复安装链接，再继续改源码。
- 不要直接提交到 `master`、`main`、`dev` 或其他长期集成分支。
- 在任何会改变分支的操作前运行 `git worktree list`。
- 使用 Conventional Commits，并且不要使用 `git commit --amend`。
- PR 创建优先使用 `gh`；只有在 `gh` 不可用或失败时，才使用 GitHub connector。

## 资源

- 阅读 `references/workflow.md`，了解完整的澄清、写回、同步、Git 和 PR 工作流。
- 使用 `scripts/resolve_source_repo.sh` 通过脚本路径解析并验证源仓库。
- 编辑现有 skill 前，使用 `scripts/compare_skill_copies.sh <skill-name>` 校验本地安装链接。
- 使用 `assets/clarification-template.md` 组织写入前的澄清内容。
- 创建 PR 正文时使用 `assets/pr-body-template.md`。
