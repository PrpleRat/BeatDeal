#!/usr/bin/env python3
"""Copie les garde-fous pipeline TestFlight vers les autres apps iOS du monorepo."""
from __future__ import annotations

import pathlib
import re
import shutil

SOURCE = pathlib.Path(__file__).resolve().parents[1]
COPY_CI = (
    "testflight-pipeline-version",
    "verify-testflight-pipeline.sh",
    "install-signing.sh",
    "stage-signing-ci.sh",
)
INSERT = (
    "      - name: Vérifier alignement pipeline TestFlight\n"
    "        run: bash ci/verify-testflight-pipeline.sh\n"
    "\n"
)
REPOS = (
    SOURCE,
    SOURCE.parent / "CarenceScan",
    SOURCE.parent / "TrajOc",
    pathlib.Path(r"C:\Users\jouet\OneDrive\Documents\GitHub\Panium"),
    pathlib.Path(r"C:\Users\jouet\OneDrive\Documents\GitHub\TrajOc"),
)


def patch_testflight(workflow: pathlib.Path) -> bool:
    text = workflow.read_text(encoding="utf-8")
    if "verify-testflight-pipeline.sh" in text:
        return False
    marker = "for f in ci/*.sh; do tr -d"
    idx = text.find(marker)
    if idx == -1:
        raise RuntimeError(f"LF prep introuvable dans {workflow}")
    end = text.find("\n\n", idx)
    if end == -1:
        raise RuntimeError(f"fin bloc LF introuvable dans {workflow}")
    text = text[: end + 2] + INSERT + text[end + 2 :]
    workflow.write_text(text, encoding="utf-8")
    return True


def sync_repo(repo: pathlib.Path) -> None:
    ci = repo / "ci"
    is_source = repo.resolve() == SOURCE.resolve()
    if not is_source:
        for name in COPY_CI:
            shutil.copy2(SOURCE / "ci" / name, ci / name)
        guard = repo / ".github" / "workflows" / "ci-pipeline-guard.yml"
        guard.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(SOURCE / ".github" / "workflows" / "ci-pipeline-guard.yml", guard)

    signing = ci / "signing-from-api.sh"
    if signing.exists():
        signing.write_text(
            signing.read_text(encoding="utf-8").replace(
                "install-signing.sh +", "install_signing.py +"
            ),
            encoding="utf-8",
        )

    for workflow in (repo / ".github" / "workflows").glob("*-testflight.yml"):
        if patch_testflight(workflow):
            print(f"patched {workflow}")


def main() -> None:
    for repo in REPOS:
        if not repo.is_dir():
            print(f"skip missing {repo}")
            continue
        sync_repo(repo)
        print(f"synced {repo.name}")


if __name__ == "__main__":
    main()
