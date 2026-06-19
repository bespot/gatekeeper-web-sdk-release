# Bespot Gatekeeper Web SDK

Browser SDK for Bespot Gatekeeper antifraud checks. This repository contains **pre-built SDK bundles**, integration documentation, and starter templates.

## Documentation

| Document | Description |
|----------|-------------|
| [Integration guide](docs/integration-guide.md) | Full end-to-end integration reference |
| [Authentication](docs/authentication.md) | JWT access tokens and OAuth (server-side) |
| [Error reference](docs/error-reference.md) | Error handling rules and `error.name` catalog |
| [SDK versioning](docs/versioning.md) | SDK package version vs application version |
| [Templates](templates/) | Copy-paste HTML and config starters |

Official authentication API reference: [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

## Installation

### npm (recommended)

```bash
npm install @bespot/gatekeeper-web-sdk
```

```ts
import SafeSDK from '@bespot/gatekeeper-web-sdk'
```

### CDN / script tag (no build step)

Download `safe-sdk.esm.min.js` or `safe-sdk.umd.min.js` from the [Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases) page and host the files on your CDN or static origin.

## Quick start

1. **Install** — `npm install @bespot/gatekeeper-web-sdk` or download from [Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases)
2. **Configure** — four runtime fields: `baseUrl`, `apiKey`, `applicationId`, `applicationVersion` ([runtime configuration](docs/integration-guide.md#5-runtime-configuration))
3. **Authenticate** — obtain a JWT from your backend ([authentication](docs/authentication.md))
4. **Integrate** — `await sdk.initialize(jwt)` then `await sdk.check()` ([integration sequence](docs/integration-guide.md#6-integration-sequence))

```ts
const sdk = new SafeSDK({
  baseUrl: 'https://gatekeeper.bespot.dev/v2',
  apiKey: 'your-api-key',
  applicationId: 'your-app-id',
  applicationVersion: 'your-app-version',
})

await sdk.initialize(jwt)

const result = await sdk.check()
if (result instanceof Error) {
  console.error('Check failed:', result.name)
} else {
  console.log('Check passed:', result)
}
```

Starter pages: [templates/integration-esm.html](templates/integration-esm.html), [templates/integration-umd.html](templates/integration-umd.html).

## License

Use of the SDK is governed by [LICENSE](LICENSE).

## Support

See [Support](docs/integration-guide.md#16-support) in the integration guide.
