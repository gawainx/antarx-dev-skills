---
name: skill-creation-closeout
description: 在新建或更新的本地 skill 尚未由 antarx-dev-skills 托管时，确认是否导入仓库；用户明确要求导入时直接执行。已经托管的 skill 更新不触发。
---

# Skill Creation Closeout

## 1. 判断是否需要导入

确认 skill 的实际来源和仓库位置。优先使用当前 antarx-dev-skills 工作目录，否则使用 `skill-improvement-ax` 的 `scripts/resolve_source_repo.sh` 定位；无法定位时询问路径，不通过安装同步修复定位问题。

搜索仓库 `skills/` 下是否已有同名 skill，并检查本地安装项的真实路径。已托管或链接到仓库源码的 skill 直接结束，不重复导入。仅浏览、安装第三方 skill 或批量安装请求不触发本流程。

## 2. 确认导入范围

用户已经要求导入时沿用授权；否则说明本地来源、推荐分类和目标目录，询问是否纳入托管。用户拒绝时结束。用户同意托管但未指定分类时，按内容选择仓库已有分类，不再次询问。

## 3. 导入并验证

1. 确认本地 `SKILL.md` 存在、frontmatter 的 `name` 与目录名一致，且仓库尚无同名 skill。
2. 不导入黑名单项：`skill-creator`、`skill-installer`、`swiftui-macos-llm-chat-module`。
3. 运行 `scripts/import_installed_skill.sh <skill-name> <category>`，仅把本地 skill 复制到仓库源码，不删除或替换原安装项。
4. 检查新增文件、frontmatter、相关引用和实际差异，按仓库规则提交。

导入不附带安装、重新安装或安装同步；不以全部技能已安装作为验证条件。只有用户另行明确要求安装时，才处理指定技能和目标。
