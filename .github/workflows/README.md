# Release pipeline

```
PR ──────────────► ci.yml            analyze + test

merge to master ─► release.yml
                     ├─ verify   uses ./.github/workflows/ci.yml   (gate)
                     └─ tag      reads `version:` from pubspec.yaml
                                 no-op if the tag or the pub.dev version exists
                                 pushes vX.Y.Z  [needs RELEASE_TOKEN]
                                      │
                                      ▼
                   publish.yml   on tag vX.Y.Z
                                 dart-lang/setup-dart publish.yml → OIDC → pub.dev
```

## How to cut a release

Bump `version:` in `pubspec.yaml`, add a matching `## X.Y.Z` heading to
`CHANGELOG.md`, and merge to `master`. That is the whole process.

A merge that does not change `version:` produces no tag and no publish, so
ordinary merges are safe.

## Why the merge does not publish directly

pub.dev only accepts automated publishing when the workflow run is triggered by
a **git tag push** — the OIDC token's `ref` claim has to match the tag pattern
registered on the package admin page. A run triggered by `push: branches:
[master]` is rejected. Hence the two-step chain: master merge creates the tag,
the tag triggers the publish.

## One-time setup

1. **Publish `1.0.0` manually.** Automated publishing cannot create a package
   that does not exist yet. From a checkout with Flutter installed:

   ```bash
   flutter pub publish --dry-run   # inspect the file list first
   flutter pub publish
   ```

2. **Enable automated publishing.** On
   <https://pub.dev/packages/lableb_flutter_sdk/admin> → *Automated publishing*
   → *Enable publishing from GitHub Actions*:

   - Repository: `Lableb-Labs/Flutter-SDK`
   - Tag pattern: `v{{version}}`

   The tag pattern must stay in sync with the `on.push.tags` glob in
   `publish.yml`.

3. **Create the `RELEASE_TOKEN` secret.** A fine-grained personal access token
   scoped to `Lableb-Labs/Flutter-SDK` with **Contents: Read and write**, saved
   as a repository secret named `RELEASE_TOKEN`. A GitHub App installation
   token works too and is preferable long-term.

   This is required because tags pushed with the default `GITHUB_TOKEN` do not
   trigger other workflows — GitHub's recursion guard. Without it the tag is
   created but `publish.yml` never runs.

## Optional hardening

Create a `pub.dev` GitHub environment with required reviewers, tick **Require
GitHub Actions environment** on the pub.dev admin page, and uncomment the
`with: environment: pub.dev` lines in `publish.yml`. The environment is encoded
in the OIDC token, so someone with push access cannot bypass it by editing the
workflow.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Tag appears, `publish.yml` never runs | `RELEASE_TOKEN` missing, expired, or lacking Contents: write — the tag was pushed as `GITHUB_TOKEN`. |
| pub.dev rejects the publish | The registered tag pattern does not match the pushed tag, or the repository field does not match. |
| `tag` job fails on the CHANGELOG check | `version:` was bumped without adding a `## X.Y.Z` heading to `CHANGELOG.md`. |
| `tag` job says "already published" | The version in `pubspec.yaml` is already on pub.dev. Bump it. |
