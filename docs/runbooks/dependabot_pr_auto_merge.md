# Dependabot PR Review and Auto-Merge Runbook

## Purpose
This runbook standardizes how to review Dependabot pull requests for GitHub Actions updates and safely enable auto-merge.

## Scope
- Target: Dependabot PRs that update GitHub Actions versions (for example, `actions/upload-artifact`).
- Primary workflow file in this repository: `.github/workflows/ci.yml`.

## Prerequisites
- `gh` CLI is authenticated and can access `ryz310/my_api_client`.
- You have permission to comment on and merge PRs.
- Branch protection rules and required checks are configured on GitHub.

## Step-by-step
1. Open PR metadata and changed files.

```bash
gh pr view <PR_NUMBER> --json number,title,author,baseRefName,headRefName,files,body
```

2. Review the exact diff and identify action version changes.

```bash
gh pr diff <PR_NUMBER>
```

3. Compare old and new action versions and summarize impact.
- Focus on major version changes and runtime requirements (Node version, runner minimum version, breaking changes).
- For `actions/upload-artifact`, verify compatibility notes in the official release notes.

4. Enable auto-merge with squash merge.

```bash
gh pr merge <PR_NUMBER> --auto --squash
```

5. Check merge state.

```bash
gh pr view <PR_NUMBER> --json state,mergeStateStatus,autoMergeRequest
```

6. If state is `BEHIND`, request Dependabot rebase.

```bash
gh pr comment <PR_NUMBER> --body "@dependabot rebase"
```

7. Re-check status until the branch is up to date and required checks pass.

```bash
gh pr view <PR_NUMBER> --json state,mergeStateStatus,statusCheckRollup,autoMergeRequest
```

## Done criteria
- `autoMergeRequest` is enabled.
- `mergeStateStatus` is not `BEHIND`.
- Required CI checks are green.
- PR is merged automatically, or clearly waiting only on pending required checks.

## Failure handling
- If rebase does not start, re-run comment:
  - `@dependabot rebase`
- If checks fail, inspect failing jobs and decide:
  - fix in a follow-up PR, or
  - close/ignore that update version with Dependabot commands.
- If the update introduces breaking changes, disable auto-merge and switch to manual review with explicit test evidence.
