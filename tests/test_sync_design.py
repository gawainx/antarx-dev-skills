"""Verify DESIGN ownership checks using isolated installation destinations."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SYNC_SCRIPT = Path(__file__).resolve().parents[1] / "scripts/sync_to_local.sh"


class DesignLinkTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sync-design-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        (self.repo / "scripts").mkdir(parents=True)
        shutil.copy2(SYNC_SCRIPT, self.repo / "scripts/sync_to_local.sh")
        skill = self.repo / "skills/example/sample"
        skill.mkdir(parents=True)
        (skill / "SKILL.md").write_text("---\nname: sample\ndescription: Example\n---\n")
        self.source = self.repo / "DESIGN.md"
        self.source.write_text("Project design rules\n")
        self.target = self.root / "codex/DESIGN.md"
        self.target.parent.mkdir()
        self.codex_skills = self.root / "codex/skills"
        self.claude_skills = self.root / "claude/skills"
        config = {
            "CODEX_SKILLS_DIR": self.codex_skills,
            "CLAUDE_SKILLS_DIR": self.claude_skills,
            "GROK_SKILLS_DIR": self.root / "grok/skills",
            "CODEX_DESIGN_FILE": self.target,
            "CODEX_AGENTS_FILE": self.root / "codex/AGENTS.md",
        }
        (self.repo / ".env").write_text(
            "".join(f"{key}={value}\n" for key, value in config.items())
        )

    def run_sync(self, *options, targets="claude,codex"):
        return subprocess.run(
            ["bash", str(self.repo / "scripts/sync_to_local.sh"),
             "--targets", targets, *options],
            cwd=self.repo, capture_output=True, text=True,
        )

    def assert_rejected(self, *options):
        result = self.run_sync(*options)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected source:", result.stderr)
        self.assertIn("Review the existing entry", result.stderr)
        self.assertFalse(self.codex_skills.exists())
        self.assertFalse(self.claude_skills.exists())

    def test_missing_target_is_created(self):
        result = self.run_sync()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.target.readlink(), self.source)
        self.assertTrue((self.codex_skills / "sample").is_symlink())

    def test_project_link_is_preserved(self):
        self.target.symlink_to(self.source)
        before = self.target.lstat()
        result = self.run_sync()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.target.lstat().st_ino, before.st_ino)
        self.assertEqual(self.target.readlink(), self.source)

    def test_relative_project_link_is_preserved(self):
        relative = os.path.relpath(self.source, self.target.parent)
        self.target.symlink_to(relative)
        result = self.run_sync()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(str(self.target.readlink()), relative)

    def test_foreign_link_and_source_are_preserved(self):
        other = self.root / "personal-rules.md"
        other.write_text("Personal rules\n")
        self.target.symlink_to(other)
        self.assert_rejected()
        self.assertEqual(self.target.readlink(), other)
        self.assertEqual(other.read_text(), "Personal rules\n")

    def test_broken_foreign_link_is_preserved(self):
        other = self.root / "missing-rules.md"
        self.target.symlink_to(other)
        self.assert_rejected()
        self.assertEqual(self.target.readlink(), other)

    def test_regular_file_is_preserved_even_with_matching_content(self):
        self.target.write_text(self.source.read_text())
        self.assert_rejected()
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(self.target.read_text(), self.source.read_text())

    def test_directory_is_preserved(self):
        self.target.mkdir()
        child = self.target / "keep.txt"
        child.write_text("Keep this\n")
        self.assert_rejected()
        self.assertEqual(child.read_text(), "Keep this\n")

    def test_dry_run_rejects_foreign_target(self):
        self.target.write_text("Personal rules\n")
        self.assert_rejected("--dry-run")
        self.assertEqual(self.target.read_text(), "Personal rules\n")

    def test_dry_run_does_not_create_target(self):
        result = self.run_sync("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.target.exists())
        self.assertFalse(self.codex_skills.exists())
        self.assertFalse(self.claude_skills.exists())

    def test_non_codex_install_does_not_check_or_change_design(self):
        self.target.write_text("Personal rules\n")
        result = self.run_sync(targets="claude")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.target.read_text(), "Personal rules\n")
        self.assertFalse(self.codex_skills.exists())
        self.assertTrue((self.claude_skills / "sample").is_symlink())


if __name__ == "__main__":
    unittest.main()
