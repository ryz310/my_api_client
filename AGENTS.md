# AGENTS.md

## Branch Creation Rule
- Always create a new branch from `master`.
- Before creating a branch, update local `master` with the latest commits from `origin`.
- Example flow:
  1. `git checkout master`
  2. `git fetch origin`
  3. `git pull --ff-only origin master`
  4. `git checkout -b codex/<new-branch-name>`
