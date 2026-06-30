# Changelog

All notable changes to the distributed Gatekeeper Web SDK packages in this repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-06-24

**Upstream release:** [v1.0.1](https://github.com/bespot/gatekeeper-web-sdk/releases/tag/v1.0.1)

### Added

- `applicationId`, `applicationVersion`, and `userId` getters on the SDK instance
- `lastCheckResult` getter — last `check()` outcome (success or failure)

### Changed

- `subscribe()` no longer accepts arguments; periodic interval comes from server configuration
- **Breaking:** `sdk.result` renamed to `sdk.lastCheckResult`

### Removed

- **Breaking:** `isConfigured`, `getLastGeolocationFailure()`, and `getDeviceSeed()` removed from public API

---

## [1.0.0] - 2026-06-22

**Upstream release:** [v1.0.0](https://github.com/bespot/gatekeeper-web-sdk/releases/tag/v1.0.0)

### Added

- `setAccessToken` API — rotate the JWT after first `initialize` without re-registering the device
- Structured error types with stable `error.name` values
- `StorageUnavailable` error
- `getLastGeolocationFailure()` helper
- Fetch timeout with `AbortController` (30 s); requests never hang indefinitely
- Storage isolation — localStorage, sessionStorage, cookie, and IndexedDB written independently

### Changed

- Runtime configuration is supplied by the host application at serve time; credentials never baked into the bundle
- Storage handling hardened for restricted browser environments
- **Breaking:** Runtime config requires `baseUrl`, `apiKey`, `applicationId`, and `applicationVersion`
- **Breaking:** Bundle filenames are `safe-sdk.esm.min.js` and `safe-sdk.umd.min.js`
