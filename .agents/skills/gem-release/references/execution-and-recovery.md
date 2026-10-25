# Execution and partial-failure recovery

Read this when preparing a runtime, adapting gem_comet, or resuming a release. No command in this reference is an instruction to mutate GitHub without the user's relevant authorization.

## Credential gate before release work

Run this gate immediately when starting or resuming release execution, before the environment setup and release steps below. Only minimal read-only configuration inspection and credential checks belong before it passes.

1. Identify the selected authentication path and required credentials from the request and current configuration. For gem_comet/pr_comet preparation, confirm the required GitHub authentication can be supplied to the actual tool process (normally `GITHUB_ACCESS_TOKEN`) and that Git push authentication is available. A full release also requires authenticated access with repository contents-write permission for the final GitHub Release draft. An existing authorized GitHub CLI credential bridge can satisfy this requirement; anonymous repository access or a connected tool that cannot authenticate gem_comet cannot. Do not silently substitute an unrelated credential source or merely assume a host credential reaches Docker.
2. Check presence/nonemptiness without printing values, then validate the selected authentication with a read-only authenticated request. Verify applicable repository access through non-secret permission metadata where available. Test the intended container/process boundary with a minimal check if Docker will be used; do not install gem_comet or run release preparation to perform this check. Do not print successful response payloads containing private information or expose a credential through command arguments, logs, environment dumps, or persistent files.
3. For publication, distinguish GitHub Actions Trusted Publishing/OIDC from local API-key publishing. The Trusted Publishing path does not require a local RubyGems API key. Verify its non-secret workflow/configuration evidence and required provisioned authentication mechanism; do not attempt to read remote secret values or demand unrelated keys such as coverage tokens. If the configured path actually requires a provisioned secret and its availability cannot be established safely, stop and report that it is unverified. Token issuance during a later OIDC workflow is not itself a missing local secret.
4. On any missing, empty, inaccessible, invalid, or unverified required credential, end release execution immediately. Do not continue tool installation, branch updates, CHANGELOG work, partial preparation, GitHub mutations, or other release steps. A runner or script implementing this gate must return nonzero on failure. Report the credential/mechanism name and configuration location without its value; ask for configuration outside chat, not disclosure. Network/tool errors that prevent verification are an unverified gate, not proof that the credential is absent.
5. After configuration is corrected, rerun the gate before resuming from existing release state. This credential-specific stop takes precedence over guidance elsewhere to continue independent work after a failure. Passing the gate verifies prerequisites, not permission to perform actions beyond the user's authorized scope.

## Preflight the actual execution environment

Prefer an installed Ruby matching the repository development baseline. If the host shim points to an uninstalled Ruby, use the repository's Docker development image. Read the current baseline and image configuration; do not bake a Ruby patch version into this skill.

Before mounting the working checkout for mutation, verify these inside the intended container:

- `ruby --version`, `gem_comet version`, and the selected Bundler/Gemfile.
- Git can see the expected repository and branch, and its effective `user.name` and `user.email` are nonempty. Some pr_comet versions read `git config` and override `GIT_AUTHOR_*` with empty values. Passing only author environment variables is therefore insufficient. Configure the container's Git identity or explicitly pass the identity to the tool, then verify it.
- The effective Git status matches the host. Host global excludes do not automatically exist in Docker. Inspect specific mismatches with `git check-ignore -v`; provide the relevant ignore rules to the container. Do not delete existing `.DS_Store`, tmp directories, or user files to manufacture a clean checkout, or add broad ignore patterns that conceal release edits.
- The immediate credential gate has passed for this execution environment. Recheck it if the authentication path or environment changes. Do not read or display `.envrc`, credential stores, or tokens as diagnostic content.

Install gem_comet into an isolated temporary tool directory when needed, not into the product Gemfile. Keep temporary adapters, tool gems, and validation fixtures outside the repository. The installed gem's source is authoritative for the code that will execute; its repository master may differ.

Use existing authentication through the approved credential mechanism. If a container needs a token, transfer it without logging it or persisting it in a file, remote URL, Git config, committed content, or script. Disable shell tracing. A process-only Git HTTP header and `origin` push target can avoid token-bearing URLs. Do not print the full environment or Docker inspection output containing credentials.

## Adapt narrowly before the first mutation

Inspect the installed release orchestration, PR creation, Git command handling, bundle updater, and changelog generator. In older gem_comet/pr_comet versions:

- The preparation branch may be hard-coded as `update/vVERSION`. Map only this newly created topic branch to the required `codex/` prefix. Do not rename `master` or the configured release branch.
- A full `bundle update` may occur as part of version preparation. Limit it to the agreed scope. Path-gem synchronization must match each lockfile's actual current entry, not a single assumed previous version.
- Shell failures may not propagate and the CLI may print an error while exiting successfully. The release PR may be created even when preparation commits or the update PR failed.
- Generated CHANGELOG text may include only merge commits, empty categories, ungrouped bullets, duplicate dependency bumps, verification-app bumps, or noncanonical remote URLs.
- The final stage may try to launch a desktop browser from inside the container. Printing the resulting PR links is sufficient in this environment.

Use an adapter only for controls the installed tool lacks, and inspect it before running with credentials. Verify transformations on temporary inputs and use a mutation-free preview/stub where practical. Check subprocess failures at their source and stop before the next stage; an outer CLI exit code alone is not sufficient. Avoid accumulating one-off retries and private-method calls into an unreviewed general-purpose launcher.

Keep requested dependency changes separate from accidental bulk updates. Do not leave newly resolved package versions merely because gem_comet generated them. If discarding tool-generated changes, identify the exact files/hunks and confirm that no user changes are included.

## Record stage evidence

After each mutating stage, inspect actual state before proceeding:

| Stage | Evidence |
| --- | --- |
| Branch creation | Expected topic name and correct base SHA |
| File generation | Version, CHANGELOG, all path-gem entries, scoped diff |
| Commit | A new commit containing the intended files, clean index/worktree |
| Push | Remote branch SHA equals the intended local SHA |
| Update PR | Existing/open PR with the intended head and base |
| Release PR | Existing/open PR from configured base to publication branch |
| Validation | Successful required checks on the final relevant SHA |
| Publication | Workflow result, tag SHA, RubyGems version |
| Final Release draft | Matching existing tag, CHANGELOG title/body, draft URL and `draft: true` |

Record this in the chat or PR description as appropriate; do not commit a per-run state file or credentials to the project. Follow the repository's file-based body safety rules if using `gh` for Markdown descriptions.

## Preserve generated PR content

Treat gem_comet's generated TODO checklist and attribution as maintained PR content, not disposable scaffold. This applies to both the update and release PRs, including when adding the repository-required `Purpose of this change` section or refreshing validation results.

Before a body update:

1. Fetch the current body from GitHub; do not reconstruct it from a remembered template. Retain user-written content as well as generated content.
2. Compose a minimal edit against that body. Add the purpose and other explanations before or after existing sections; update an existing validation section in place when appropriate. Preserve the TODO heading, every checklist item, its checkbox state, and the original attribution wording/link unless the user requests a change to that content or the CHANGELOG completion rule below applies. A release-version change may require corresponding version fields to be updated; it does not justify removing the checklist. Do not mark other review checkboxes complete merely because automation has run.
3. Review the before/after diff. Confirm the generated checklist and attribution remain intact, with no duplicate sections or lost user edits. A tool accepting a full replacement `body` still requires this preservation check; it is not permission to replace the entire description with a new summary.
4. Re-fetch before submission if the body may have changed while composing the edit, and reconcile changes rather than overwriting them. After submission, read back the body and verify that the generated sections and added information are present.

For example, an update PR can retain this block verbatim while additional explanatory sections are added around it (version values below are illustrative):

```markdown
# TODO

- [ ] Check version numbering: v2.2.0 (was v2.1.0)
- [ ] Edit the CHANGELOG.md

Generated by [gem_comet](https://github.com/ryz310/gem_comet)
```

Do not substitute `Generated with ...` for the original attribution when documenting adapters. Explain those adaptations separately. If generated content was already removed, report the loss and propose restoring it from trustworthy evidence; do not treat its absence as proof that future descriptions should omit it.

CHANGELOG completion rule: after editing the release entry, reviewing it against the repository's CHANGELOG rules and merged release changes, and confirming the finished edit is present in the update PR's current diff, change only `- [ ] Edit the CHANGELOG.md` to `- [x] Edit the CHANGELOG.md`. Make this completion update without requesting another confirmation. Retain the checklist item text, other checkbox states (including version-number review), TODO heading, attribution, and user additions. Leave the CHANGELOG item unchecked while content is merely generated, incomplete, or not yet reflected in the PR. Include the checkbox change in the before/after review and read-back verification above.

## Resume instead of restarting blindly

1. Read current Git status, branch, commit history, remote SHAs, and both PRs. Determine which stages actually completed; do not infer completion from tool output alone.
2. Preserve successful work. If the update PR is missing but the release PR exists, reuse the release PR and create only the missing preparation PR. It is not ready for publication yet.
3. If generated changes are uncommitted, inspect them and repair the failed prerequisite. Resume from that point. Reverting/regenerating is appropriate only for identified task-owned changes and when it is simpler than preserving them; do not reset user work or delete branches with useful commits.
4. After repairs, re-inspect the diff and rerun only checks invalidated by those repairs. A changed head invalidates previous CI evidence for merging that head.
5. If a merge API call fails, re-read the PR: auto-merge may have completed concurrently. Confirm the merged state and SHA rather than retrying immediately.
6. If a stage fails again for the same reason after a targeted repair, stop automatic retries at that stage. Diagnose from non-secret evidence, explain what remains, and ask only for the missing decision or authority. Continue independent authorized work when it does not depend on the failed stage.

For publication failures, inspect whether the gem or tag already exists before considering a retry. Creating release PRs, merging them, dispatching a workflow, and publishing are distinct states. Never automatically yank a gem, reuse a published version, force-update a release tag, or bypass branch protection.

## Create the final GitHub Release draft

This is the final step of a full authorized release, after the gem is published and the existing version tag is verified. Editing this skill does not create a live Release draft. A preparation-only request still ends with the PR handoff. If this step fails after gem publication, report the published gem/tag and incomplete draft stage; retry only draft creation after diagnosing the failure, never the gem publication workflow.

Use [v2.1.0](https://github.com/ryz310/my_api_client/releases/tag/v2.1.0) as the formatting reference, not as a fixed version or a source of old release notes:

- Its title is `v2.1.0 (Aug 11, 2026)`, matching the CHANGELOG version heading without the `## ` prefix.
- Its body starts with category headings such as `### Security` and contains that version's CHANGELOG entries with PR and contributor links. It does not include the CHANGELOG's document heading, version heading, or previous versions.

Procedure:

1. Confirm the successful publication workflow, intended version, and remote tag SHA. Read `CHANGELOG.md` from that tag's commit, not from an unrelated working branch. The selected version heading and gem version must agree. Use the release date already recorded in that heading rather than substituting the draft creation date.
2. Extract only that version's section, ending before the next level-two version heading. Use the heading text as the Release title and the remaining category content as the body. Retain the finalized category order, bullets, links, and compatibility notes. Do not use automatically generated GitHub notes in place of the reviewed CHANGELOG or append a second copy of the entries. Write the body to a temporary Markdown file outside the repository.
3. Check authenticated release listings for the exact tag, including drafts; checking only the latest published Release does not detect an existing draft. Reuse and report a matching draft. Preserve existing human edits; do not overwrite its title/body without reviewing the differences and the authorized update scope. If a published Release already exists for that tag, report the existing artifact instead of creating a duplicate or converting it back to draft.
4. For a missing Release, create it explicitly as a draft using the existing verified tag. With GitHub CLI, use the equivalent of the following command, supplying the verified tag, reviewed title, and temporary body-file path:

   ```sh
   gh release create "$release_tag" --repo ryz310/my_api_client \
     --verify-tag --draft --title "$release_title" --notes-file "$release_notes_file"
   ```

   `--verify-tag` prevents this operation from implicitly creating a tag at a default branch tip. Do not create or move a tag as a shortcut, attach arbitrary build artifacts, or mark a stable version as a prerelease. For an actual prerelease version, use the intended prerelease setting explicitly. Use the connected GitHub API when it provides equivalent existing-tag and draft safeguards.
5. Read back the resulting Release: confirm the intended tag and SHA, title, body, prerelease setting, and `draft: true`. Include its URL in the final handoff, clearly distinguishing RubyGems publication from the still-unpublished GitHub Release. Never clear the draft flag or publish it as part of this step.

## Propose upstream issues

Do not let a consumer-side workaround hide a tool defect. When an observed failure or recurring adapter requirement suggests an upstream improvement:

1. Record the installed tool versions, minimal environment/reproduction, observed result, expected behavior, and any workaround. Separate observed evidence from inferred causes; do not claim an unexecuted reproduction has been tested. Use dummy identities and isolated repositories or stubbed APIs, never live publication, for reproductions.
2. Inspect the relevant installed code and current upstream code, and search existing issues, including closed reports. If upstream already fixes the behavior, recommend the applicable upgrade rather than filing the old defect again. If a matching issue exists, link it instead of creating a duplicate; new comments also require user authorization.
3. Route Git command execution, identity resolution, commit/push error propagation, and generic PR creation to `ryz310/pr_comet`. Route release-stage sequencing, dependency-update controls, release-specific CHANGELOG behavior, and CLI exit status to `ryz310/gem_comet`. Split independent defects into separate issues and cross-link dependent fixes. A missing local prerequisite alone is not proof of a tool defect; explain the missing validation or configurable behavior that would improve the tool.
4. Present the proposed repository/title, user-visible impact, expected result, and meaningful regression-test criteria. Mention whether the release can continue safely with a bounded workaround. Do not pause unrelated authorized work solely to wait for an upstream fix.
5. Post only when explicitly authorized. Keep reports technical and credential-safe, without personal paths, secret-bearing logs, or KPT content. Report created links and unresolved limitations. Issue creation does not authorize implementing fixes in the other repositories.

Known reports from the Docker release incident are listed below for duplicate detection, not as permanent release blockers. Read their current status and the installed version before relying on them:

- [pr_comet #503](https://github.com/ryz310/pr_comet/issues/503): preserve environment-based Git identity when Git config is unset.
- [pr_comet #504](https://github.com/ryz310/pr_comet/issues/504): propagate failed Git mutations while preserving expected probe fallback behavior.
- [gem_comet #444](https://github.com/ryz310/gem_comet/issues/444): stop release orchestration after preparation failure and return nonzero CLI status.
