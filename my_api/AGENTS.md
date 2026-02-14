# my_api AGENTS.md

## Migration Policy (Jets -> Rails 8.1)

- Do not keep a renamed backup directory for the old Jets app (for example, `my_api_legacy_jets/`).
- Keep traceability in Git history instead:
  1. Make sure Jets-based `my_api/` changes are committed before replacement work.
  2. Replace `my_api/` with a newly created Rails 8.1 API app in the same path.
  3. Remove Jets-specific implementation after migration is complete.

## Ruby Version Policy for my_api

- The Rails 8.1 `my_api/` must use the latest Ruby version.
- Update patch level to the latest available release in that Ruby line when possible.
- Keep version-related files aligned during migration:
  - `my_api/.ruby-version`
  - `my_api/Dockerfile` (when added/updated)
  - CI and compose settings that build/run `my_api`
