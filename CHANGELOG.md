# Changelog

All notable changes to the distributed Gatekeeper Web SDK packages in this repository.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Package filenames: `gatekeeper-web-sdk-{version}.tgz`

## [1.0.0] - 2026-06-10

**Package:** `packages/gatekeeper-web-sdk-1.0.0.tgz`  
**Upstream release:** [v1.0.0](https://github.com/bespot/gatekeeper-web-sdk/releases/tag/v1.0.0)

### Added

- `setAccessToken` API
- Structured error types with stable `error.name` values
- `StorageUnavailable` error
- `getLastGeolocationFailure()` helper

### Changed

- Runtime configuration is supplied by the host application
- Storage handling for restricted browser environments
- Breaking: Runtime config requires `baseUrl`, `apiKey`, `applicationId`, and `applicationVersion`
- Breaking: Bundle paths are `sdk/safe-sdk.*.min.js` inside the tarball
