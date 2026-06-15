# Bespot Gatekeeper Web SDK

Browser SDK for Bespot Gatekeeper antifraud checks. This repository contains **pre-built SDK packages**, integration documentation, and starter templates.

## Documentation

| Document | Description |
|----------|-------------|
| [Integration guide](docs/integration-guide.md) | Full end-to-end integration reference |
| [Authentication](docs/authentication.md) | JWT access tokens and OAuth (server-side) |
| [Error reference](docs/error-reference.md) | Error handling rules and `error.name` catalog |
| [SDK versioning](docs/versioning.md) | SDK package version vs application version |
| [Templates](templates/) | Copy-paste HTML and config starters |

Official authentication API reference: [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

## Available SDK versions

| Version | Package | Status |
|---------|---------|--------|
| 1.0.0 | [packages/gatekeeper-web-sdk-1.0.0.tgz](packages/gatekeeper-web-sdk-1.0.0.tgz) | **Current** |

### Package contents

Each `gatekeeper-web-sdk-{version}.tgz` extracts to:

```text
sdk/
  safe-sdk.esm.min.js
  safe-sdk.umd.min.js
```

```bash
tar -xzf packages/gatekeeper-web-sdk-1.0.0.tgz
```

Host the `sdk/` files on your CDN or static origin, then follow the [integration guide](docs/integration-guide.md).

## Quick start

1. **Download** — `packages/gatekeeper-web-sdk-1.0.0.tgz`
2. **Extract** — `tar -xzf packages/gatekeeper-web-sdk-1.0.0.tgz`
3. **Configure** — four runtime fields: `baseUrl`, `apiKey`, `applicationId`, `applicationVersion` ([runtime configuration](docs/integration-guide.md#5-runtime-configuration))
4. **Authenticate** — obtain a JWT from your backend ([authentication](docs/authentication.md))
5. **Integrate** — `await sdk.initialize(jwt)` then `await sdk.check()` ([integration sequence](docs/integration-guide.md#7-integration-sequence))

Starter pages: [templates/integration-esm.html](templates/integration-esm.html), [templates/integration-umd.html](templates/integration-umd.html).

## License

Use of the SDK packages is governed by [LICENSE](LICENSE).

## Support

See [Support](docs/integration-guide.md#17-support) in the integration guide.
