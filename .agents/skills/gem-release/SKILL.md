---
name: gem-release
description: Prepare, review, resume, or publish a my_api_client gem release using gem_comet and its update/release PR workflow. Use for ryz310/my_api_client releases, including Docker execution and partial-failure recovery; ordinary Dependabot maintenance is outside this skill.
---

# Gem Release

Operate on `ryz310/my_api_client`. Read the current checkout's `AGENTS.md`, README Deployment section, `.gem_comet.yml`, and release workflow before acting. These are authoritative for current repository rules; this skill supplies execution and recovery guidance.

## Immediate credential gate

At the start of every release execution or resume, identify the authentication required by the requested actions using only minimal read-only configuration inspection, then check its availability before any other release work. Follow the [credential gate procedure](references/execution-and-recovery.md#credential-gate-before-release-work). If a required credential is missing, empty, inaccessible in the intended execution environment, invalid, or cannot be verified, stop the skill immediately. Do not switch/update branches, install tools, edit files, generate release artifacts, commit/push, create/update PRs, merge, or dispatch publishing while blocked. Do not continue independent release work or retry the full release command to discover credentials later.

Report only the missing credential name or authentication mechanism, where it must be configured, and that release work has stopped. Ask the user to configure it through the appropriate environment or service; never request the secret value in chat. Resume only after it is configured and this gate passes again. This gate does not execute when merely creating, editing, or explaining this skill. Do not require unrelated secrets for an offline review or a publishing mechanism that does not use them.

## Scope and authorization

Translate the user's request into preparation, PR merge, and publication scope. “Start a release” normally means create reviewable update and release PRs. Merging into the configured release branch triggers publication; creating a PR does not. Do not enable auto-merge on the release PR as part of preparation.

Reuse authorization already given for the relevant actions; do not request it again. This skill adds no blanket approval requirement. Return a decision to the user when version policy, a compatibility change, or an external action is outside the authorized scope. Authorization for unrelated Dependabot merges does not itself authorize publishing a gem.

Creating or updating this skill never invokes release automation.

## Inspect before starting or resuming

- Confirm repository identity, worktree status, current branch, local/remote branch SHAs, existing open update/release PRs, and whether the target tag/version is already published. Do not print credential-bearing remote URLs.
- Distinguish a fresh run from a partial run **before** switching branches or creating anything. Preserve user changes and existing release work.
- For a fresh preparation, update local `master` from `origin` and re-read `AGENTS.md`, following the repository's branch rule. Use `codex/` for a newly created preparation branch. The configured publication branch is an existing workflow target, not a new topic branch to rename.
- Determine the previous published release from GitHub/RubyGems and reachable Git history; do not rely only on tagger dates or merge-commit parsing.
- Inspect all merged PRs since that release, including squash merges. Separate gem changes, root dependencies, Actions, and verification-app changes.
- Determine the target version from actual API/compatibility changes and the user's intent. Check log format changes, error text, and newly rejected argument combinations as well as method signatures. Explain the chosen version and migrations; never carry a version number from an earlier run into a new release.

## Prepare gem_comet execution

Use [references/execution-and-recovery.md](references/execution-and-recovery.md) when setting up Docker, adapting the installed tool, or recovering from failure. Read it before the first external mutation.

Verify the runtime, tool version, Git identity and effective ignore rules, authentication availability, and installed tool behavior. Do not execute a full release command to discover whether these prerequisites work.

`gem_comet release VERSION` creates an update PR and then a release PR. Tool defaults may conflict with repository branch rules, may update every dependency, and may continue after a failed Git command. Inspect the installed implementation rather than assuming it is transactional.

Agree the dependency-update scope with the current request. In ordinary release preparation, preserve already-reviewed dependency versions and synchronize the local path gem entry across tracked lockfiles. An unrestricted `bundle update` is not implied by “start a release.” Use a small, reviewed temporary adapter if the installed tool lacks the needed controls; keep it outside the repository and do not silently change the user's tool choice. Explain material adaptations in the PR.

## Make preparation reviewable

- Update the configured version file and every tracked lockfile containing the `my_api_client` path gem. Read their actual old versions, which may differ. Keep path-gem dependency constraints consistent with the gemspec without updating unrelated packages.
- Use the current `AGENTS.md` CHANGELOG rules: keep category order, omit empty categories, use `-`, consolidate repeated bumps, and exclude verification/test-app dependency bumps from Dependabot entries.
- Supplement generated changelog text with squash-merged PRs and migration notes. Use canonical GitHub links without embedded usernames or credentials. Classify actual compatibility breaks honestly; do not hide them by choosing a convenient heading.
- PR titles and descriptions are English and include `Purpose of this change`. Link the two PRs, explain the version choice, dependency scope, compatibility notes, validation, and merge order. Attach both PRs to the current chat with the app tool when available.
- Preserve the existing PR body, especially gem_comet's generated `# TODO`, checklist items and checkbox states, and `Generated by [gem_comet](https://github.com/ryz310/gem_comet)` attribution. Add purpose, compatibility, and validation sections around that content instead of replacing it. Use the [PR body preservation procedure](references/execution-and-recovery.md#preserve-generated-pr-content) before updating either release-related PR.
- When CHANGELOG editing and review are complete and reflected in the update PR's current diff, change `- [ ] Edit the CHANGELOG.md` to `- [x] Edit the CHANGELOG.md` without another confirmation. This is an intentional exception to preserving checkbox states; retain the item text and all other checklist states. Generating a draft alone does not complete this task.
- Treat new concrete security alerts as findings: inspect the affected manifest and patched version. Make a narrow fix when authorized by the release scope; otherwise report the unresolved finding. Do not treat verification-app exposure as a published-gem dependency change.

## Propose upstream tool improvements

When release work exposes a reproducible defect or a recurring limitation in `gem_comet` or `pr_comet`, propose an issue in the responsible tool repository even if a local workaround succeeds. Check the installed behavior, current upstream implementation, and existing issues before recommending a new issue; distinguish tool defects from missing local configuration or repository-specific preferences.

Use the [upstream issue guidance](references/execution-and-recovery.md#propose-upstream-issues) to prepare evidence, route the issue, and reuse existing reports. Propose a concrete issue with expected behavior and regression coverage. Creating an issue requires explicit user authorization covering that report; reuse authorization already given and do not post automatically just because the skill was invoked. Tool fixes are separate work unless included in the user's request. Continue independent authorized release work when the finding does not block it, and include unresolved findings and issue links in the handoff.

## Verify and hand off

Check the final diff and whitespace, gem version/lockfile alignment, and required repository validation. Use the repository's Docker command policy for local checks. For a version `.rb` change, ensure RuboCop ran and passed, even though the edit is small. Successful CI on the exact final commit may provide this evidence; do not redundantly rerun a completed matrix without a new concern.

Confirm the final preparation head SHA, CI results, remaining findings, and clean worktree. Distinguish tests/builds, skipped automation jobs, and externally delivered coverage. A green upload job may contain a skipped step or tolerate upload errors: inspect step outcomes and, when needed, a non-secret delivery confirmation before claiming external delivery.

For preparation-only requests, leave both PRs unmerged and report their URLs, validation, and the next authorized step. Do not finish with only a plan when preparation is authorized and still executable.

## Merge and publish when authorized

1. Confirm final preparation changes and checks, then merge the update PR into the configured base branch.
2. Confirm the base branch contains the intended version and finalized CHANGELOG. The release PR follows that branch; wait for its updated-head CI rather than reusing checks from before the version bump.
3. Confirm the release PR's exact head and approved publication scope, then merge into the publication branch. Do not also manually dispatch the workflow or run `rake release` unless recovery requires it and it is authorized.
4. Observe the release workflow, pushed tag, and published RubyGems version. Do not equate PR merge or workflow dispatch with successful publication. If partially published, inspect existing artifacts before retrying; do not overwrite/delete a published version or move its tag as an automatic recovery step.

At a completion point, offer a proportionate KPT in the conversation only. Propose durable procedural improvements in this skill, not a growing release checklist in `AGENTS.md`; edit guidance only within the user's request.
