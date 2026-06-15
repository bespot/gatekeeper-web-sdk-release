# SDK versioning

How SDK package versions relate to your application configuration.

---

## Two version concepts

| Term | Example | What it is |
|------|---------|------------|
| **SDK package version** | `1.0.0` in `gatekeeper-web-sdk-1.0.0.tgz` | Version of the JavaScript bundle in `packages/` |
| **Application version** | `1.0.0` in `SafeSDK` config | Your app identity in Gatekeeper API URL paths |

They are **independent**. Upgrading the SDK tarball does not change your `applicationVersion` unless you choose to update it in Bespot and in your config.

---

## Package naming and layout

| Item | Value |
|------|-------|
| Archive | `packages/gatekeeper-web-sdk-{semver}.tgz` |
| Extract command | `tar -xzf packages/gatekeeper-web-sdk-{semver}.tgz` |
| Bundles | `sdk/safe-sdk.esm.min.js`, `sdk/safe-sdk.umd.min.js` |

Filenames inside the archive are always `safe-sdk.*` — not `gatekeeper.*` or `dist/`.

---

## Selecting a version

1. Use the **Current** row in the [README version table](../README.md#available-sdk-versions).
2. Pin a specific `.tgz` in production rather than always tracking latest.
3. Read [CHANGELOG](../CHANGELOG.md) before upgrading.

---

## Upgrade procedure

1. Download the newer `gatekeeper-web-sdk-X.Y.Z.tgz` into `packages/` (or replace your hosted extract).
2. Extract and deploy `sdk/safe-sdk.esm.min.js` and/or `sdk/safe-sdk.umd.min.js`.
3. In staging, re-test:
   - `new SafeSDK(config)` with all four runtime fields
   - `await initialize(jwt)`
   - `await check()`
   - `subscribe` / `unsubscribe` if used
4. Deploy to production after checks pass.
5. Keep the previous `.tgz` until all environments have migrated.

---

## Upstream source

SDK packages are built from [github.com/bespot/gatekeeper-web-sdk](https://github.com/bespot/gatekeeper-web-sdk). Each GitHub Release tag `vX.Y.Z` produces `gatekeeper-web-sdk-X.Y.Z.tgz`.

