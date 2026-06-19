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

## Bundle naming

| Item | Value |
|------|-------|
| npm package | `@bespot/gatekeeper-web-sdk` |
| GitHub Releases | `https://github.com/bespot/gatekeeper-web-sdk-release/releases` |
| Bundle filenames | `safe-sdk.esm.min.js`, `safe-sdk.umd.min.js` |

Filenames are always `safe-sdk.*` — not `gatekeeper.*`.

---

## Selecting a version

1. Check [GitHub Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases) for the latest version.
2. Pin a specific version in production rather than always tracking latest.
3. Read [CHANGELOG](../CHANGELOG.md) before upgrading.

---

## Upgrade procedure

1. Run `npm install @bespot/gatekeeper-web-sdk@latest` **or** download newer bundles from [GitHub Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases) and replace your hosted files.
2. In staging, re-test:
   - `new SafeSDK(config)` with all four runtime fields
   - `await initialize(jwt)`
   - `await check()`
   - `subscribe` / `unsubscribe` if used
4. Deploy to production after checks pass.
5. Keep the previous `.tgz` until all environments have migrated.

---

## Upstream source

SDK packages are built from [github.com/bespot/gatekeeper-web-sdk](https://github.com/bespot/gatekeeper-web-sdk). Each GitHub Release tag `vX.Y.Z` produces `gatekeeper-web-sdk-X.Y.Z.tgz`.

