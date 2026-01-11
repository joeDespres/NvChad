#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage:
  fast-forward.sh [target-branch] [source-branch]

Defaults:
  target-branch: main
  source-branch: v2.0

Notes:
  Uses refs/heads/* to avoid tag/branch ambiguity (e.g. v2.0).
EOF
  exit 0
fi

target_branch="${1:-main}"
source_branch="${2:-v2.0}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: not inside a git repo" >&2
  exit 1
}

cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: working tree not clean; commit/stash first." >&2
  git status --porcelain
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/${target_branch}"; then
  echo "ERROR: target branch not found: ${target_branch}" >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/${source_branch}"; then
  echo "ERROR: source branch not found: ${source_branch}" >&2
  exit 1
fi

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [[ "$current_branch" != "$target_branch" ]]; then
  git checkout "$target_branch" >/dev/null
fi

git merge --ff-only "refs/heads/${source_branch}"
git status -sb
