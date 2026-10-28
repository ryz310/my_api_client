---
name: dependabot-maintenance
description: Review Dependabot pull requests in ryz310/my_api_client and, when authorized, merge compatible updates sequentially. Report skipped updates, compatibility concerns, and actual CI outcomes.
---

# Dependabot Maintenance

Review Bundler and GitHub Actions updates in `ryz310/my_api_client`. Use the current repository rules and the [runbook](../../../docs/runbooks/dependabot_pr_auto_merge.md) for automation policy, command examples, and recovery limits. This skill supplies review and execution decisions; creating or explaining it does not run maintenance.

## Scope and authorization

- For review-only requests, do not edit files, post comments, or merge. Reuse existing authorization for sequential maintenance without asking again for every compatible PR.
- Preserve explicit holds and exclusions. Skip problematic updates and continue independent authorized PRs. Return unresolved support-policy, public-API compatibility, permissions, and merge-authority decisions to the user with evidence.
- Maintenance authorization covers necessary Dependabot refresh commands within the runbook's safeguards. It does not authorize publishing a gem, changing GitHub settings or automation policy, creating issues, or posting general review comments.

## Inspect before acting

Read the current checkout's `AGENTS.md`, `.github/dependabot.yml`, CI and Dependabot auto-merge workflows, and the runbook. Confirm repository identity, worktree state, and authentication availability without retrieving or displaying token values or credential-bearing URLs.

Preserve user changes. For execution, refresh local `master` and re-read `AGENTS.md` as the runbook requires. PR operation alone needs no topic branch; an authorized file change follows the repository's branch-creation rule. A review-only request can inspect the latest remote state without switching the user's branch.

Inventory the requested PRs and record their author, dependency and ecosystem, head/base SHAs, merge state, checks, and existing auto-merge requests. Confirm the Dependabot identity, not just a label or branch name. Separate root runtime/development dependencies from verification-app dependencies.

## Review the actual update

Inspect the exact diff and official release notes or upstream changes, rather than relying only on the PR title or description.

- **Bundler:** Include related lockfile updates, required Ruby/Rails versions, dependency constraints, APIs used by this repository, and changes to exceptions, timeouts, or HTTP behavior. A minor version does not by itself prove compatibility.
- **GitHub Actions:** Match the new tag/SHA to the official release. Check runner/runtime requirements, inputs, credential handling, permissions, triggers, and command changes. Preserve the repository's action-pinning policy.
- Distinguish eligibility for the existing automatic workflow from an individually reviewed merge authorized by the user. An update outside the automatic policy still requires a compatibility decision; do not silently broaden that policy or the supported matrix.

## Validate and merge one PR at a time

1. Read the current head/base SHAs and checks. For `BEHIND`, start with `@dependabot rebase`; consider `@dependabot recreate` when rebasing cannot resolve a conflict or the update needs regeneration. Follow the runbook's edit-preservation checks, waits, and retry limits. Use other Dependabot commands only when their effects fit the authorized task; skipping does not authorize ignore commands.
2. After a refresh, inspect the resulting state, new head SHA, and exact diff. Wait for CI on that head; do not reuse results from an older commit or assume the regenerated patch is equivalent.
3. Verify required checks and relevant tests/builds. Missing, pending, failed, or skipped checks are not evidence of a successful validation. Inspect failures before deciding whether the cause is the update or its execution environment; do not rerun blindly.
4. Immediately before merging, recheck the PR head, current target-branch SHA, mergeability, and checks. If another merge advanced `master`, refresh and validate against its new state. Never bypass branch protections or rulesets to merge a stale green branch.
5. Merge using the reviewed head SHA (`expected_head_sha` in the merge API or `--match-head-commit` with `gh`), and the repository's usual merge method unless the user specified another. A head mismatch requires inspection before any retry.
6. Confirm `MERGED` and the merge commit before proceeding. An auto-merge reservation or queue entry is still pending, not a completed merge. Do not reserve multiple PRs when the user requested sequential merges.

Use successful CI on the exact final commit when it covers the needed validation. If checks are missing or a concrete concern remains, use the Docker validation policy in `AGENTS.md` for appropriate additional checks; do not duplicate a completed matrix without a reason.

## Concurrent automation and skipped updates

- Existing automation may merge other PRs while validation runs. Inspect existing reservations, refresh the base as needed, and report those merges separately from your own. Do not disable unrelated automation to force serial execution.
- If Dependabot closes a PR as no longer needed, inspect the actual dependency version on `master`, any successor PR, and cooldown configuration. Report the observed outcome as closed/skipped, not merged or updated without proof. Keep an inferred cause separate from a confirmed one; do not reopen merely to defeat cooldown.
- Check auto-merge state before skipping. Remove reservations created by this maintenance run that could merge a rejected update. Report remaining reservations from other actors/workflows and any risk of a later automatic merge; do not silently change unrelated automation policy.
- At the recovery limit, stop commands for that PR, record why it is skipped or needs a decision, and continue independent work. Do not change dependency ignore rules or compatibility policy as a shortcut.

## Coverage and Qlty

Inspect individual steps for coverage collation, artifact preservation, Qlty upload, and the missing-token notification. A green `upload-coverage` job alone does not establish external delivery; check step results and a non-secret delivery confirmation when needed.

For Dependabot-triggered `pull_request` runs, secrets come from Dependabot secrets rather than ordinary Actions secrets. A missing token there does not prove that a normal PR lacks the token. If asked about normal PRs, inspect their actual upload steps. See [GitHub's restrictions](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-on-actions#restrictions-when-dependabot-triggers-events).

Report an expected guarded upload skip separately from tests and builds. It is not a successful upload and is not by itself proof of a dependency regression. Do not bypass required checks or copy tokens to make the status green.

## Verify and report

Refresh the PR inventory at the end and account for newly arrived or unprocessed updates within the requested scope. For each PR, distinguish merged, skipped, automatically closed, and pending/decision-needed outcomes. Include the update, reasoning, CI evidence, material skips or unverified behavior, and any decision required from the user.

Keep records in this conversation unless another destination was requested. At a completion point, share a proportionate KPT and propose durable improvements to this skill or its runbook; keep `AGENTS.md` to broad rules and references. Do not post the retrospective to GitHub without explicit authorization.
