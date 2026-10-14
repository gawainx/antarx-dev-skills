# antarx-dev-skills

提供需求釐清、設計規劃、開發與除錯用的 Agent Skills，適用於 Codex、Claude Code、Grok Build 等工具。技能統一透過 [skills CLI](https://github.com/vercel-labs/skills) 安裝與管理。請參閱[英文版 README](README.md)。

## 安裝

```bash
npx skills add gawainx/antarx-dev-skills
```

依照提示選擇技能與目標 Agent。預設會安裝至目前專案；加上 `-g` 可全域安裝。例如，為 Codex 全域安裝：

```bash
npx skills add gawainx/antarx-dev-skills -g -a codex
```

## 技能一覽

| 技能 | 用途 |
| --- | --- |
| [requirement-clarification](skills/planning/requirement-clarification/SKILL.md) | 釐清目標、範圍與驗收條件 |
| [design-plan-doc-writer](skills/planning/design-plan-doc-writer/SKILL.md) | 根據已確認的需求撰寫設計文件與開發計畫 |
| [using-git-worktrees](skills/git/using-git-worktrees/SKILL.md) | 建立並準備隔離的 worktree |
| [merge-worktree-to-source-branch](skills/git/merge-worktree-to-source-branch/SKILL.md) | 將 worktree 的變更以快轉方式合併回來源分支 |
| [dispatching-parallel-agents](skills/collaboration/dispatching-parallel-agents/SKILL.md) | 將互相獨立的工作分派給平行 Agent |
| [systematic-debugging](skills/quality/systematic-debugging/SKILL.md) | 根據證據調查原因並驗證修正 |
| [ui-layout-discipline](skills/ui/ui-layout-discipline/SKILL.md) | 檢查並修正 UI 版面配置 |
| [swiftui-macos-settings-window-pattern](skills/ui/swiftui-macos-settings-window-pattern/SKILL.md) | 使用 SwiftUI 建立 macOS App 設定視窗 |
| [dida-task-creator](skills/integration/dida-task-creator/SKILL.md) | 使用本機 dida CLI 建立 TickTick 工作 |
| [writing-flavor-review](skills/writing/writing-flavor-review/SKILL.md) | 審閱文章中的生硬或 AI 風格，並提出精簡的修改建議 |

## 更新與移除技能

```bash
# 查看此儲存庫提供的技能
npx skills add gawainx/antarx-dev-skills --list

# 查看全域安裝的技能
npx skills list -g

# 更新或移除指定的全域技能
npx skills update requirement-clarification -g
npx skills remove requirement-clarification -g
```

安裝位置與紀錄由 CLI 管理。修改此儲存庫中的技能原始檔後，請使用 CLI 更新已安裝的技能。

## 儲存專案文件

需求釐清、設計與開發計畫預設保存在同一份文件中，並逐章補充。若 DEVONthink MCP 可用，請使用 [awesome-devonthink](https://github.com/gawainx/awesome-devonthink/tree/master/using-dt-skills) 提供的 `dt-writing-project-documents` 技能儲存；該技能需另外提供。若 MCP 未安裝或未啟用，請將文件儲存在專案根目錄的 `docs/`。

## Codex／Claude 全域檔案

此儲存庫也提供 [DESIGN.md](DESIGN.md) 與 [AGENTS.root.md](AGENTS.root.md)，可依需求分別安裝。`AGENTS.root.md` 可同時作為 Codex `AGENTS.md` 與 Claude Code `CLAUDE.md` 的安裝來源。請在本機儲存庫根目錄執行：

```bash
# 預覽或安裝 DESIGN（僅 Codex）
./scripts/sync_to_local.sh --dry-run
./scripts/sync_to_local.sh

# 同時安裝 DESIGN 與 Codex AGENTS
./scripts/sync_to_local.sh --sync-agents

# 同時安裝 DESIGN 與 Claude CLAUDE.md
./scripts/sync_to_local.sh --sync-claude

# 檢查 DESIGN；加上 --check-agents 或 --check-claude 可一併檢查對應連結
./scripts/doctor.sh
```

這兩個腳本只處理全域檔案。目標路徑設定請參閱 [.env.example](.env.example)。若現有 DESIGN 檔案並非來自本專案，腳本會停止。替換現有 AGENTS 檔案需明確指定 `--sync-agents --force-agents`；替換現有 CLAUDE.md 則需指定 `--sync-claude --force-claude`。

## 維護

技能原始檔位於 `skills/<category>/<skill-name>/`，開發規範請參閱 [AGENTS.md](AGENTS.md)。請在此儲存庫中編輯、提交並推送原始檔；技能的安裝與更新由使用者透過 CLI 執行。
