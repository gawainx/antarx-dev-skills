---
name: completion-progress-recorder
description: "在用户提及“验收通过”“测试通过”“总结变更”“提交更改”“提交改动”“保持工作区干净”“清理工作区”“收尾记录”等表示当前需求或开发计划已完成的语义时，执行收尾记录流程：检查或创建 progress.md、检查并清理 git 工作区（必要时提交）、基于开发计划或提交区间生成约150字简体中文连续段落总结，并以“YYYY.MM.dd|当前HEAD前8位: 总结内容”格式仅追加写入 progress.md。"
---

# Completion Progress Recorder

## 执行目标
在开发收尾场景下，确保工作区干净且进度记录可审计。严格执行“只追加、不改写历史”的记录规则。

## 执行流程
1. 检查 `progress.md` 是否存在。
2. 若存在，读取全文并识别写作风格与最后一条记录中的提交哈希，记为 `hash1`；若不存在，则创建空的 `progress.md`。
3. 执行 `git status --porcelain` 检查工作区。
4. 若存在未提交改动，先完成提交并得到新提交哈希，记为 `hash2`；若已干净，则将当前 `HEAD` 视为 `hash2`。
5. 生成约150字简体中文总结：
   - 若当前上下文包含开发计划，优先总结开发计划的已执行内容与结果。
   - 若无开发计划，则总结 `hash1..hash2` 区间内的主要改动文件与变更要点。
6. 获取当天日期（格式 `YYYY.MM.dd`）与当前 `HEAD` 前8位短哈希，按以下格式追加到 `progress.md`：
`- ({curr_git_head_hash:8}) : {curr_date_yyyy_mm_dd} {content}`

## 内容与格式约束
- 仅使用简体中文。
- 每条记录中的 `{content}` 必须是一段连续中文文本，不使用列表、编号、小标题或多段结构。若当前上下文包含开发计划，则需要补充开发计划文件的文件名。例如 `plan/model_design.md`
- 禁止修改或重排 `progress.md` 任何历史条目，只允许文件末尾追加。
- 若无法得到 `hash1`（例如首次创建文件），明确说明“基于当前提交状态生成总结”，并仍按同一格式追加（日期使用当天，格式为 `YYYY.MM.dd`）。

## Git 提交约束
在需要提交时，提交信息必须满足 Conventional Commits：
- 格式：`<type>: <description>`
- `type` 仅允许：`feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert`
- `description` 至少 10 个字符，且必须具体描述技术改动
- 禁止空消息、无意义消息（如 `fix`、`update`）、禁止 `--amend`

## 结果校验
执行结束后自检：
1. 工作区是否干净。
2. `progress.md` 是否仅新增一条记录。
3. 新记录是否符合 `- ({curr_git_head_hash:8}) {curr_date_yyyy_mm_dd} : 连续中文段落` 格式。
4. 总结是否约150字且与实际改动一致。

## 重试与防重
- 先构造完整候选条目字符串 `entry_line`，再执行去重检查，最后才允许追加。
- 追加前必须执行：`grep -Fqx \"$entry_line\" progress.md`。
- 若检查命中，说明该条目已存在，禁止再次追加；仅继续后续 `git add/commit` 或结束流程。
- 若命令在“已写入但未提交”阶段失败，重试时必须先做同样的去重检查，禁止直接再次写入。
