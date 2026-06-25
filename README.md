# Bespot Gatekeeper Web SDK

[![npm version](https://img.shields.io/npm/v/@bespot/gatekeeper-web-sdk)](https://www.npmjs.com/package/@bespot/gatekeeper-web-sdk)
[![GitHub release](https://img.shields.io/github/v/release/bespot/gatekeeper-web-sdk-release)](https://github.com/bespot/gatekeeper-web-sdk-release/releases)
[![Module format](https://img.shields.io/badge/modules-ESM%20%2B%20UMD-blue)](docs/integration-guide.md#4-distribution-format-selection)
[![Platform](https://img.shields.io/badge/platform-browser-lightgrey)](docs/integration-guide.md#2-bespot-prerequisites)
[![License](https://img.shields.io/badge/License-Integrator%20License-red)](LICENSE)

Browser SDK for Bespot Gatekeeper antifraud checks. This repository contains **pre-built SDK bundles**, integration documentation, and starter templates.

## Prerequisites

Before integrating, sign in at **[gatekeeper.bespot.com](https://gatekeeper.bespot.com)** to create your account and obtain your API key and other credentials for SDK runtime configuration.

## Documentation

SDK integration guides live in this repository. Official Bespot product documentation is at **[docs.bespot.com](https://docs.bespot.com)**.

| Document | Description |
|----------|-------------|
| [Integration guide](docs/integration-guide.md) | Full end-to-end integration reference |
| [Authentication](docs/authentication.md) | JWT access tokens and OAuth (server-side) |
| [Error reference](docs/error-reference.md) | Error handling rules and `error.name` catalog |
| [SDK versioning](docs/versioning.md) | SDK package version vs application version |
| [Templates](templates/) | Copy-paste HTML and config starters |

Official authentication API reference: [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

## Installation

SDK bundles are distributed via **npm** and **GitHub Releases** (`safe-sdk.esm.min.js`, `safe-sdk.umd.min.js`). Each release includes both ESM and UMD builds — download and host directly; no extraction step required.

### npm (recommended)

Requires **Node.js** on your development machine to run `npm install`. The SDK itself runs in the browser — Node is not needed at runtime.

```bash
npm install @bespot/gatekeeper-web-sdk
```

```ts
import SafeSDK from '@bespot/gatekeeper-web-sdk'
```

### CDN / script tag (no build step)

No Node.js required. Download `safe-sdk.esm.min.js` or `safe-sdk.umd.min.js` from the [Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases) page and host the files on your CDN or static origin.

## Quick start

1. **Account** — sign in at [gatekeeper.bespot.com](https://gatekeeper.bespot.com) and collect your credentials
2. **Install** — `npm install @bespot/gatekeeper-web-sdk` or download from [Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases)
3. **Configure** — four runtime fields: `baseUrl`, `apiKey`, `applicationId`, `applicationVersion` ([runtime configuration](docs/integration-guide.md#5-runtime-configuration))
4. **Authenticate** — obtain a JWT from your backend ([authentication](docs/authentication.md))
5. **Integrate** — `await sdk.initialize(jwt)` then `await sdk.check()` ([integration sequence](docs/integration-guide.md#6-integration-sequence))

```ts
const sdk = new SafeSDK({
  baseUrl: 'https://gatekeeper.example.com',
  apiKey: '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs',
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
