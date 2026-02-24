# Dependabot PR Review and Auto-Merge Runbook

## Purpose
This runbook standardizes how to review Dependabot pull requests for GitHub Actions updates and safely enable auto-merge.

## Scope
- Target: PRs created by Dependabot that update GitHub Actions versions (for example, `actions/upload-artifact`).
- Primary workflow file in this repository: `.github/workflows/ci.yml`.
- This runbook is for PR operation only, so creating a dedicated local work branch is normally unnecessary.

## Prerequisites
- `gh` CLI is authenticated and can access `ryz310/my_api_client`.
- You have permission to comment on and merge PRs.
- Branch protection rules and required checks are configured on GitHub.
- Before starting the runbook, update local `master` and re-read `AGENTS.md`.

```bash
git checkout master
git fetch origin
git pull --ff-only origin master
sed -n '1,260p' AGENTS.md
```

## Step-by-step
1. Open PR metadata and changed files.

```bash
gh pr view <PR_NUMBER> --json number,title,author,baseRefName,headRefName,files,body
```

2. Validate that the PR is in scope.
- Confirm `author.login` is `app/dependabot`.
- Confirm changed files are GitHub Actions workflow/dependabot update files and the update target is GitHub Actions.
- If either condition is not met, stop this runbook and notify the user that manual review is required.

3. Review the exact diff and identify action version changes.

```bash
gh pr diff <PR_NUMBER>
```

4. Summarize impact from the diff and release notes.
- Explain what functional changes are introduced by each action version bump.
- Explain whether existing workflows are affected (runtime requirements, minimum runner version, breaking changes, behavior changes such as credential handling).
- For major version updates, verify compatibility notes in the official release notes.
- Post this summary to the user and ask for explicit approval to proceed.

5. Only after user approval, enable auto-merge.
- Use repository default merge method unless there is an explicit instruction to force squash merge.

```bash
gh pr merge <PR_NUMBER> --auto
# Optional (only when squash is explicitly required):
# gh pr merge <PR_NUMBER> --auto --squash
```

6. Check merge state.

```bash
gh pr view <PR_NUMBER> --json state,mergeStateStatus,autoMergeRequest
```

7. If `mergeStateStatus` is `BEHIND`, post a Dependabot rebase comment (also only after user approval from Step 4).

```bash
gh pr comment <PR_NUMBER> --body "@dependabot rebase"
```

8. Re-check status until the branch is up to date and required checks pass.
- After posting `@dependabot rebase`, wait 1 minute before retrying.
- If rebase has not started after 1 minute (for example, `mergeStateStatus` is still `BEHIND`), post `@dependabot rebase` again.
- Retry comment posting up to 2 times in total. If it is still `BEHIND` after the second retry, stop and escalate for manual follow-up.
- Run each command step-by-step and inspect output after each `gh pr view` call before deciding the next action.

```bash
# Check current state
gh pr view <PR_NUMBER> --json state,mergeStateStatus,statusCheckRollup,autoMergeRequest

# If mergeStateStatus is BEHIND, wait 1 minute
sleep 60

# Re-check after waiting
gh pr view <PR_NUMBER> --json state,mergeStateStatus,statusCheckRollup,autoMergeRequest

# If still BEHIND, post @dependabot rebase (up to 2 retries total)
# gh pr comment <PR_NUMBER> --body "@dependabot rebase"
```

## Done criteria
- `autoMergeRequest` is enabled.
- `mergeStateStatus` is not `BEHIND`.
- Required CI checks are green.
- PR is merged automatically, or clearly waiting only on pending required checks.
- The user-approved impact summary is recorded in the operation log/comment thread.

## Failure handling
- If rebase does not start, wait 1 minute, confirm `mergeStateStatus` is still `BEHIND`, then re-run comment (up to 2 retries total):
  - `@dependabot rebase`
- Execute checks and retries sequentially (check -> wait -> re-check -> comment) rather than chaining commands without inspection.
- If it is still `BEHIND` after 2 retries, stop automated retries and notify the user for manual follow-up.
- If checks fail, inspect failing jobs and decide:
  - fix in a follow-up PR, or
  - close/ignore that update version with Dependabot commands.
- If the update introduces breaking changes, disable auto-merge and switch to manual review with explicit test evidence.
