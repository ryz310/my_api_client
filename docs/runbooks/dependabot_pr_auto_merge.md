# Dependabot PR Review and Auto-Merge Runbook

## Purpose

This runbook documents the existing auto-merge policy and command procedures for reviewing, refreshing, and merging Dependabot updates. Use the [Dependabot Maintenance skill](../../.agents/skills/dependabot-maintenance/SKILL.md) for agent review decisions, sequential execution, and reporting.

## Scope

- Target: Dependabot PRs for Bundler dependencies and GitHub Actions, including root dependencies and verification apps.
- Relevant configuration: `.github/dependabot.yml`, `.github/workflows/ci.yml`, and `.github/workflows/dependabot-auto-merge.yml`.
- This runbook is for PR operation only, so creating a dedicated local work branch is normally unnecessary.

## Prerequisites

- `gh` CLI is authenticated and can access `ryz310/my_api_client`.
- For execution, confirm permission to comment on and merge PRs and authorization covering the requested actions. A review-only request does not authorize writes.
- Inspect the branch protection or rulesets and required checks currently applied on GitHub. Do not bypass them.
- Before execution, update local `master` and re-read `AGENTS.md`. Preserve user changes; review-only work need not switch the user's branch.

```bash
git checkout master
git fetch origin
git pull --ff-only origin master
sed -n '1,260p' AGENTS.md
```

## Auto-merge workflow policy

- Keep `package-ecosystem` decisions separated in `.github/workflows/dependabot-auto-merge.yml`.
- Apply independent conditions for each ecosystem to avoid cross-ecosystem condition mixing.
- For `bundler` ecosystem auto-merge:
  - Verification apps (`rails_app/*` and `my_api`) are eligible regardless of update type
    (including major), because bundle update failures there do not affect the published gem and are
    gated by CI/branch protection.
  - Exception: a major update of the `rails` gem itself under `rails_app/*` is NOT auto-merged,
    because a Rails major bump is treated as an explicit support-matrix decision that requires manual
    review. Other gems' major updates under `rails_app/*` are still auto-merged.
  - The gem itself (root `Gemfile`) is auto-merged only for `direct:development` dependencies on
    non-major updates (patch/minor).
- For `github-actions` ecosystem auto-merge, require all of the following:
  - GitHub official actions only (`actions/*` or `github/*`)
  - non-major updates only (patch/minor)
  - no changes related to `permissions` or `pull_request_target`
- CI pass/fail gating is controlled by branch protection and required checks on GitHub.
- These are the existing workflow's eligibility rules, not a blanket prohibition on individually reviewed merges authorized by the user. Do not change automation policy or supported versions as part of routine PR operation.

## Step-by-step

1. Open PR metadata and changed files.

```bash
gh pr view <PR_NUMBER> --json number,title,author,baseRefName,baseRefOid,headRefName,headRefOid,mergeStateStatus,files,body,autoMergeRequest
```

2. Validate that the PR is in scope.

- Confirm the Dependabot author (`app/dependabot` in `gh pr view`, or `dependabot[bot]` in REST API responses).
- Confirm the dependency update matches the requested Bundler or GitHub Actions scope and inspect any additional changes.
- Preserve explicit holds. Leave out-of-scope PRs untouched and report them; continue independent in-scope work.

3. Review the exact diff and identify all dependency changes, including related lockfile updates.

```bash
gh pr diff <PR_NUMBER>
```

4. Summarize impact from the diff and release notes.

- For Bundler, check required Ruby/Rails versions, dependency constraints, APIs, and behavior used by this repository.
- For Actions, check runtime and runner requirements, inputs, credential handling, and any permissions or trigger changes.
- Verify compatibility notes for major updates and any behavior changes regardless of version type.
- Share material impact with the user. Reuse an existing instruction to review and merge compatible PRs; do not ask for approval again for each PR. Without merge authorization, stop at the review result. Skip unresolved compatibility/support decisions and report the evidence.

5. Refresh an outdated PR before merging or creating an auto-merge reservation.

- For `BEHIND`, use the [refresh and recovery procedure](#refresh-and-recovery) below, then inspect the new head, diff, and checks.
- Wait for required checks and relevant tests/builds on the current head. Recheck the target branch immediately before merging; a concurrent merge may require another refresh and validation.
- Use the repository's usual merge method unless the user specifies another. Match the reviewed head SHA and never use `--admin` to bypass checks.
- Process one PR through confirmed merge before starting the next. Do not create reservations for the whole batch.

For the usual merge-commit method, after validation:

```bash
gh pr merge <PR_NUMBER> --merge --match-head-commit <REVIEWED_HEAD_SHA>
# When auto-merge is requested, reserve only this reviewed PR:
# gh pr merge <PR_NUMBER> --auto --merge --match-head-commit <REVIEWED_HEAD_SHA>
# Use --squash instead of --merge only when explicitly requested.
```

6. Verify the outcome before moving to the next PR.

```bash
gh pr view <PR_NUMBER> --json state,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup,autoMergeRequest,mergedAt,mergeCommit
```

- Confirm `MERGED` and the merge commit. An enabled auto-merge request or queue entry is still pending.
- If the head changed or the merge was refused, inspect the current state before deciding the next action.
- Refresh the PR inventory at the end to account for newly arrived or unprocessed updates in the requested scope.

## Refresh and recovery

Use necessary Dependabot commands within authorized maintenance. Start with rebase when the PR is behind:

```bash
gh pr comment <PR_NUMBER> --body "@dependabot rebase"
```

- Wait at least 1 minute before considering another command. Inspect state, head/base SHAs, checks, and Bot replies first; commands can take several minutes, so do not repost while a refresh is progressing.
- Send at most two rebase comments per PR during a maintenance run (initial request plus one retry). If no progress occurs, inspect the cause rather than retrying indefinitely.
- If rebase cannot resolve a conflict or the dependency update needs regeneration, consider `@dependabot recreate`. It overwrites edits to the PR: inspect the current head, diff, commit authors, and any human changes first. Use it only when no changes requiring preservation will be lost; otherwise skip and report the decision needed.
- Send at most one recreate comment per PR during a maintenance run. If it does not resolve the problem, stop refresh commands for that PR and continue independent PRs.
- After any refresh, inspect the actual resulting diff and wait for CI on the new head. A successful command acknowledgement is not validation.

```bash
# Inspect state before choosing a recovery action:
gh pr view <PR_NUMBER> --json state,headRefOid,baseRefOid,mergeStateStatus,statusCheckRollup,autoMergeRequest,comments
# Only after the edit-preservation checks above, if regeneration is needed:
# gh pr comment <PR_NUMBER> --body "@dependabot recreate"
```

See [GitHub's command reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-pull-request-comment-commands) for other commands. Verify their effects and authorization before using them; routine skipping does not authorize ignore commands.

## Done criteria

- Each requested PR is either confirmed merged after validation, or explicitly reported as skipped/closed or requiring a decision, with a reason.
- Pending CI or auto-merge reservations are reported as pending, never as merged.
- The impact summary and verification results are recorded in the conversation unless the user requested another destination.
- Coverage collation, artifact preservation, and actual Qlty upload outcomes are distinguished; inspect individual steps rather than inferring delivery from a green job.

## Failure handling

- Execute checks and recovery sequentially, inspecting each result. Apply the limits above rather than retrying indefinitely.
- If checks fail, inspect the failing jobs and report whether the evidence points to the dependency update or its execution environment. Skip unresolved updates; a follow-up fix, close, or ignore action needs authorization covering that action.
- If a PR is rejected or introduces unresolved breaking changes, remove auto-merge reservations created by this maintenance run. Report reservations from other actors/workflows and any remaining risk instead of silently altering unrelated automation.
- If Dependabot closes a PR as no longer needed, compare the actual version on `master`, successor PRs, and cooldown settings before describing it as updated. Distinguish observed facts from inferred causes.
- For Dependabot-triggered PR runs, ordinary Actions secrets are unavailable; Dependabot secrets are used instead. A guarded Qlty upload skip does not establish a normal-PR token failure. Do not bypass checks or copy secrets as a workaround. See [GitHub's restrictions](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-on-actions#restrictions-when-dependabot-triggers-events).
