# Bespot Gatekeeper Web SDK

[![npm](https://img.shields.io/npm/v/@bespot/gatekeeper-web-sdk?style=flat-square&logo=npm&logoColor=white)](https://www.npmjs.com/package/@bespot/gatekeeper-web-sdk)
[![release](https://img.shields.io/github/v/release/bespot/gatekeeper-web-sdk-release?style=flat-square&logo=github&label=release)](https://github.com/bespot/gatekeeper-web-sdk-release/releases)
[![Socket](https://badge.socket.dev/npm/package/@bespot/gatekeeper-web-sdk/latest)](https://socket.dev/npm/package/@bespot/gatekeeper-web-sdk/overview/latest)
[![License](https://img.shields.io/badge/License-Integrator%20License-red?style=flat-square&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC%2BaJAAADvklEQVR4nOyaXUg0VRjH%2F6u7uq66ra%2FvW%2BZGJrnaWhltq%2BlSBiH2QZkXdRFRYERGRDdFIEQE0kVliSRd1J0opWYhdNGF4mpiliBrapblVx9%2BhK7f67q7unFycHbWmXXmnNV5F%2BbHIs8z83ee579zZs6cYfVh%2B4tIZJLUboAVzYDaaAbURjOgNpoBtdEMqE3CG9Ar0F4148ESLg6G8O3oBfWkCCUG8m%2FGe3VcvOO7Tgwk%2FBDSDKiNZkBtNANqQ2sgHI5zI7QomcgiOTqO3pKkwzULMtPIro0dMtNdCrQGAkEuSE7C42WoccFRgLRUXrDqxfAUOt2YXopHn5LQGjg4JH8LrfjwZdhuERHkXMHTleTTO4LGDvj8bH1KQnsN7B7g7ny0N4h3H8lTLrS9BbOJstB50J4BUyo%2BeQ0ZaSTe2kPfOCYXsL6N4zC5Epw2VDthTOHExXlofgUvNV%2FEpU9roMDKBV8M4KNu%2BA4Fe78awsc9ZHSVFnFbKu7EM5XoGmRqVgy2eaDTjcb26O5P%2BHcL9c2Y%2BZPf8moNDMlM5cRgMLDjQ1N3LIE%2FiHfb%2BPRGCx6%2Bl76cBAwGvvsJ%2B%2BfdWyYX4Jnj0yoHfTkJGAz8MCNLNuDhY2chfTkJGAz89pcs2eQCH9%2BUBUs6fUUxGAyseGXJltYEqfUqfUUxaA34AzgMylJ6dwVpVgZlRQloDQRCcpVRPk9ntzhx6euBeM%2FFtAaMBrlKU6og9QcoK0pAayDFEN2ZFNlmQbq5R1lRAoYhJPN%2Bkp8jSP9Zp68oBoMB%2B62yZPfczserXmzv01cUg8HAA3fJkkU%2BPozN0peTgMFAlSN6fJ%2FFVQyblU%2F7xiWVBj0sNFMEgwFjCt5%2BDjppQYaRCE5Z9Qqei07RAQ3PYqwVIy3o%2BwD336GoC7Z54BEnmurFH29yr%2BDzN3BbxBXc2ovQkYjy0VI8X0Vua%2BS%2FsskBDQqWWbQrsvHfUZALczoeK8NDJej3wPMHWcSEjnDtBjiLUH2fYNIdnMDXw%2BKHKrcL0mwzGXW%2FyH2XQWugo5%2Fc0T99nXRpMuLJcvKRYmIOb34muffs963kDFANoTDw468YncEL72N%2BJZbyOIwuN%2BqaYi19IpedJ2%2Bc5pfl96LkDGztYehnEqxtcs%2BYU4uofYeMoifK4bAh3ciLlzeI%2BEs3Zv8%2B57A936PWBXsel7Z8g90D%2BU3p4vaLLZ2OjP5M0%2F%2BvFrcVNQF9MirsyMrE9CLmYp7Ss2W1n5ypjGZAbTQDaqMZUBvNgNpoBtQm4Q38FwAA%2F%2F8fNufzjhQUMgAAAABJRU5ErkJggg%3D%3D)](LICENSE)

Web SDK for Bespot Gatekeeper, a fraud prevention and location integrity platform for web
applications.

Use this SDK to run real-time fraud checks in browser sessions and receive policy results for
high-risk actions such as signup, login, checkout, reward redemption, wallet actions, account
changes, or location-restricted access.

Gatekeeper helps detect and evaluate bot traffic, AI agents, location spoofing, VPN/proxy use,
suspicious browser or device signals, multi-accounting, and abuse patterns such as bonus, promo,
or reward fraud.

## Prerequisites

Before integrating, sign up at **[gatekeeper.bespot.com](https://gatekeeper.bespot.com?utm_source=readme&utm_medium=signup&utm_campaign=gatekeeper-web-sdk&utm_content=readme-signup)** to create your account and obtain your API key and other credentials for SDK runtime configuration.

## Documentation

SDK integration guides live in this repository. Official Bespot product documentation is at **[docs.bespot.com](https://docs.bespot.com?utm_source=readme&utm_medium=docs-home&utm_campaign=gatekeeper-web-sdk&utm_content=readme-docs-home)**.

| Document | Description |
|----------|-------------|
| [Integration guide](docs/integration-guide.md) | Full end-to-end integration reference |
| [Authentication](docs/authentication.md) | JWT access tokens and OAuth (server-side) |
| [Error reference](docs/error-reference.md) | Error handling rules and `error.name` catalog |
| [SDK versioning](docs/versioning.md) | SDK package version vs application version |
| [Templates](templates/) | Copy-paste HTML and config starters |

Official authentication API reference: [Bespot Authentication Guide](https://docs.bespot.com/api/auth?utm_source=readme&utm_medium=docs-auth&utm_campaign=gatekeeper-web-sdk&utm_content=readme-docs-auth).

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

1. **Account** — sign in at gatekeeper.bespot.com and collect your credentials
2. **Install** — `npm install @bespot/gatekeeper-web-sdk` or download from [Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases)
3. **Configure** — four runtime fields: `baseUrl`, `apiKey`, `applicationId`, `applicationVersion` ([runtime configuration](docs/integration-guide.md#5-runtime-configuration))
4. **Authenticate** — obtain a JWT from your backend ([authentication](docs/authentication.md))
5. **Integrate** — `await sdk.initialize(jwt)` then `await sdk.check()` ([integration sequence](docs/integration-guide.md#6-integration-sequence))

```ts
const sdk = new SafeSDK({
  baseUrl: 'bespot-gatekeeper-base-url', // e.g. 'https://gatekeeper.bespotcompany.com'
  apiKey: 'your-api-key', // e.g. '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs'
  applicationId: 'your-app-id', // e.g. 'mywebapp.mycompany.com'
  applicationVersion: 'your-app-version', // e.g. '2.4.1'
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

## Network behavior

This SDK makes **runtime-only** HTTPS requests to the Gatekeeper API URL you configure in
`baseUrl`:

- `POST /device/{applicationId}/{applicationVersion}/register` — on `initialize()`
- `POST /device/{applicationId}/{applicationVersion}/check` — on `check()` and periodic checks

- No install scripts (`preinstall`, `postinstall`, etc.)
- No network activity during `npm install`
- Network requests occur during `initialize()`, `check()`, and optionally during periodic
  checks if you call `subscribe()` (see [periodic checks](docs/integration-guide.md#periodic-checks))
- Requests use the browser `fetch` API with a 30-second timeout, your API key, and JWT

This behavior is required for Gatekeeper fraud and location checks.

## Data collection

During `initialize()` and `check()` (and periodic checks when `subscribe()` is active), the SDK
collects browser and device signals needed for fraud prevention and location integrity:

- **Device fingerprint** — canvas, WebGL, and audio signals are hashed into a deterministic
  `device_seed` (raw fingerprint values are not transmitted)
- **Geolocation** — browser Geolocation API when the user grants permission (see
  [geolocation](docs/integration-guide.md#10-geolocation))
- **Browser and device metadata** — user agent, screen, locale, connection type, and related
  fields included in check payloads
- **Persistent identifiers** — session data stored across localStorage, sessionStorage, cookies,
  and IndexedDB for device continuity across visits

Collection happens only at runtime in the browser. There is no install-time or background data
collection outside your integration (`initialize()`, `check()`, and optional `subscribe()`).

Integrators are responsible for disclosing this behavior to end users and obtaining consent where
required by applicable privacy law and your policies.

## Distribution format

Published npm and GitHub Release artifacts are intentionally **minified** production bundles
(`safe-sdk.esm.min.js`, `safe-sdk.umd.min.js`). Source maps are not included in the npm package.

Each GitHub Release includes `SHA256SUMS` for verifying bundle integrity.

## License

Use of the SDK is governed by [LICENSE](LICENSE).

## Support

See [Support](docs/integration-guide.md#16-support) in the integration guide.
