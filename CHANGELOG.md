# Changelog

All notable changes to the distributed Gatekeeper Web SDK packages in this repository.

Package filenames: `gatekeeper-web-sdk-{version}.tgz`  

---

## [1.0.0] — 2026-06-10

**Package:** `packages/gatekeeper-web-sdk-1.0.0.tgz`  
**Upstream release:** [v1.0.0](https://github.com/bespot/gatekeeper-web-sdk/releases/tag/v1.0.0)

### Integrator-facing changes

- **Tenant-agnostic bundles** — SDK `.tgz` artifacts contain no embedded API keys, application IDs, or backend URLs. All tenant values are supplied at runtime.
- **`setAccessToken` API** — rotate JWT access tokens after the first successful `initialize()` without re-registering the device.
- **Structured errors** — failures surface as `Error` subclasses with stable `error.name` values (see [error reference](docs/error-reference.md)).
- **Storage hardening** — device id persistence handles blocked storage more safely; new `StorageUnavailable` error when persistence fails after register.
- **Geolocation metadata** — `getLastGeolocationFailure()` reports why location was empty when checks still run.


### Breaking changes from pre-1.0 integration patterns

- Runtime config requires **four** fields: `baseUrl`, `apiKey`, `applicationId`, `applicationVersion`.
- Bundle paths are `sdk/safe-sdk.*.min.js` inside the tarball (not `dist/gatekeeper.*`).
---
