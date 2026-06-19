# Changelog

## [1.0.0] — 2026-06-10

### Features

- Agnostic SDK artifacts — runtime config supplied at serve time; credentials never baked into the bundle
- `setAccessToken(jwt)` — rotate the JWT after first `initialize` without re-registering the device
- `subscribe()` / `unsubscribe()` — periodic checks driven by server-configured interval
- Unified `Failure.*` error classes for all failure modes
- Fetch timeout with `AbortController` (30 s); request never hangs indefinitely
- Storage isolation — localStorage, sessionStorage, cookie, and IndexedDB written independently; any single backend failure does not block the others
- Geolocation timeout (10 s) with 60-second in-memory position cache
