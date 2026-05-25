#!/usr/bin/env python3
"""Initialize an Obsidian vault as a Codex long-term memory store."""

from __future__ import annotations

import argparse
from pathlib import Path


MEMORY_RULES = """# Codex 记忆使用规则

这个文件夹是 Codex 的跨项目长期记忆库。它位于 Obsidian vault 内，所有内容都应该是可读、可编辑、可搜索、可 diff 的 Markdown。

## 什么时候读取

在开始较重要或持续时间较长的任务前，先快速浏览本文件，并按任务类型查看相关目录：

- 项目相关：`Projects/`
- 人物、合作方、用户画像：`Roles/`
- 可复用流程、命令、检查清单：`Workflows/`
- 重要选择、取舍、为什么这么做：`Decisions/`
- 可复用素材、模板、表达方式：`Resources/`
- 跨项目未闭环事项：`TODO.md` 和 `agent/open-loops.md`

## 什么时候写入

只有学到长期有效、之后会反复用到的信息时才写入。优先保存这些内容：

- 用户长期偏好、明确边界、反复强调的工作方式
- 项目的稳定路径、关键命令、环境差异、发布流程
- 已验证过的故障原因、修复方式、排查顺序
- 重要决策及其原因
- 跨项目待办、悬而未决的问题
- 可复用的文章结构、脚本流程、研究模板、提示词

## 不要写入

- 不要保存完整聊天记录、流水账、临时情绪、一次性中间过程
- 不要保存 Cookie、Token、API Key、密码、验证码、身份证号、银行卡、私密联系方式
- 不要把第三方平台配置、账号凭证、日志里的敏感值复制进这里
- 不要为了“显得有记忆”而写低价值总结

## 写入方式

- 优先更新已有笔记；没有合适笔记时再新建
- 每次只写小段、可检查的 Markdown
- 用明确标题、日期、来源任务、适用范围
- 事实和推断分开写，避免把猜测沉淀成规则
- 如果发现旧记忆过时，不要直接删除；先标注“已过时”并说明原因

## 收尾规则

在重要任务结束前做一次 memory closeout：

- 判断是否有长期价值内容需要写入
- 如有，更新对应文件
- 未闭环事项写入 `TODO.md` 或 `agent/open-loops.md`
- 最终回复里简短说明改了哪些记忆文件
"""

TODO_TEMPLATE = """# TODO

用于记录跨项目、长期有效、需要后续闭环的事项。

## Open

- 暂无。
"""

OPEN_LOOPS_TEMPLATE = """# Open Loops

用于记录 Codex 需要跨项目持续跟踪的未闭环事项。

## Open

- 暂无。
"""

GLOBAL_SECTION_TEMPLATE = """## Obsidian Codex 记忆

使用这个目录作为跨项目长期记忆库：

`{memory_dir}`

在开始较重要或持续时间较长的任务前，先快速浏览：

`{memory_dir}/AGENTS.md`

当你学到长期有效、之后会反复用到的信息时，更新 `{memory_dir}` 里的相关 Markdown 文件。重点保存：项目稳定路径、关键命令、用户长期偏好、明确边界、已验证的排查结论、重要决策、可复用工作流、跨项目未闭环事项。

不要保存完整聊天记录，不要写流水账，不要把临时过程当成记忆。不要保存 Cookie、Token、API Key、密码、验证码、身份证号、银行卡、私密联系方式，也不要把第三方平台配置或日志里的敏感值复制进 Obsidian 记忆。

写入规则：优先更新已有笔记；没有合适笔记时再新建。每次只写小段、可检查的 Markdown。事实和推断分开。发现旧记忆过时时，不要直接删除，先标注“已过时”并说明原因。

重要任务结束前做 memory closeout：判断是否有长期价值内容需要写入；如有，更新对应文件；未闭环事项写入 `{memory_dir}/TODO.md` 或 `{memory_dir}/agent/open-loops.md`；最终回复里简短说明改了哪些记忆文件。
"""


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments.

    Returns:
        argparse.Namespace: Parsed initializer options.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault-path", required=True, help="Path to the Obsidian vault directory.")
    parser.add_argument(
        "--global-agents-path",
        default="/Users/yat/.codex/AGENTS.md",
        help="Path to the global Codex AGENTS.md file to update.",
    )
    parser.add_argument(
        "--require-obsidian-dir",
        action="store_true",
        help="Fail if the vault directory does not contain .obsidian/.",
    )
    return parser.parse_args()


def validate_vault(vault_path: Path, require_obsidian_dir: bool) -> list[str]:
    """Validate that the vault path can be initialized.

    Args:
        vault_path: Candidate Obsidian vault path.
        require_obsidian_dir: Whether missing .obsidian should fail validation.

    Returns:
        list[str]: Non-fatal warnings discovered during validation.

    Raises:
        SystemExit: If the path is missing, not a directory, or fails strict Obsidian validation.
    """
    if not vault_path.exists():
        raise SystemExit(f"ERROR: vault path does not exist: {vault_path}")
    if not vault_path.is_dir():
        raise SystemExit(f"ERROR: vault path is not a directory: {vault_path}")

    obsidian_dir = vault_path / ".obsidian"
    if obsidian_dir.is_dir():
        return []
    if require_obsidian_dir:
        raise SystemExit(f"ERROR: vault path does not contain .obsidian/: {vault_path}")
    return [f"WARNING: .obsidian/ was not found under {vault_path}; continuing because the path is valid."]


def write_if_missing(path: Path, content: str, created: list[Path], skipped: list[Path]) -> None:
    """Write content only when a file does not already exist.

    Args:
        path: Destination file path.
        content: Markdown content to write.
        created: Collection that receives newly created files.
        skipped: Collection that receives existing files.
    """
    if path.exists():
        skipped.append(path)
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")
    created.append(path)


def ensure_global_section(global_agents_path: Path, memory_dir: Path) -> str:
    """Append the global Obsidian memory section when it is missing.

    Args:
        global_agents_path: Codex global AGENTS.md path.
        memory_dir: Initialized memory directory.

    Returns:
        str: "created", "updated", or "skipped".
    """
    section = GLOBAL_SECTION_TEMPLATE.format(memory_dir=memory_dir)
    if global_agents_path.exists():
        current = global_agents_path.read_text(encoding="utf-8")
        if "## Obsidian Codex 记忆" in current and str(memory_dir) in current:
            return "skipped"
        separator = "" if current.endswith("\n\n") else "\n\n"
        global_agents_path.write_text(current.rstrip() + separator + section.rstrip() + "\n", encoding="utf-8")
        return "updated"

    global_agents_path.parent.mkdir(parents=True, exist_ok=True)
    global_agents_path.write_text(section.rstrip() + "\n", encoding="utf-8")
    return "created"


def main() -> None:
    """Initialize the CodexMemory tree and global Codex pointer."""
    args = parse_args()
    vault_path = Path(args.vault_path).expanduser().resolve()
    global_agents_path = Path(args.global_agents_path).expanduser().resolve()

    warnings = validate_vault(vault_path, args.require_obsidian_dir)
    memory_dir = vault_path / "CodexMemory"

    dirs = [
        memory_dir,
        memory_dir / "agent",
        memory_dir / "Projects",
        memory_dir / "Roles",
        memory_dir / "Workflows",
        memory_dir / "Decisions",
        memory_dir / "Resources",
    ]
    for directory in dirs:
        directory.mkdir(parents=True, exist_ok=True)

    created: list[Path] = []
    skipped: list[Path] = []
    write_if_missing(memory_dir / "AGENTS.md", MEMORY_RULES, created, skipped)
    write_if_missing(memory_dir / "TODO.md", TODO_TEMPLATE, created, skipped)
    write_if_missing(memory_dir / "agent" / "open-loops.md", OPEN_LOOPS_TEMPLATE, created, skipped)
    global_status = ensure_global_section(global_agents_path, memory_dir)

    for warning in warnings:
        print(warning)
    print(f"memory_dir={memory_dir}")
    print(f"global_agents_path={global_agents_path}")
    print(f"global_agents_status={global_status}")
    print("directories:")
    for directory in dirs:
        print(f"- {directory}")
    print("created_files:")
    for path in created:
        print(f"- {path}")
    print("existing_files:")
    for path in skipped:
        print(f"- {path}")


if __name__ == "__main__":
    main()
