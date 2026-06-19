# Bespot Gatekeeper Web SDK

Browser SDK for the Bespot Gatekeeper anti-fraud platform.

## Installation

### npm (recommended)

```bash
npm install @bespot/gatekeeper-web-sdk
```

### CDN / direct script

Download `safe-sdk.esm.min.js` or `safe-sdk.umd.min.js` from the [Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases) page.

```html
<!-- UMD: exposes SafeSDK on window -->
<script src="safe-sdk.umd.min.js"></script>
```

## Quick Start

```ts
import SafeSDK from '@bespot/gatekeeper-web-sdk'

const sdk = new SafeSDK({
  baseUrl: 'https://gatekeeper.bespot.dev/v2',
  apiKey: 'your-api-key',
  applicationId: 'your-app-id',
  applicationVersion: 'your-app-version',
})

await sdk.initialize(jwt) // registers the device; jwt from your auth server

const result = await sdk.check()
if (result instanceof Error) {
  console.error('Check failed:', result.name)
} else {
  console.log('Check passed:', result)
}
```

## Configuration

Supply credentials at runtime — never bake them into your build.

### Option A — constructor argument

```ts
const sdk = new SafeSDK({
  baseUrl: 'https://gatekeeper.bespot.dev/v2',
  apiKey: 'your-api-key',
  applicationId: 'your-app-id',
  applicationVersion: 'your-app-version',
})
```

### Option B — global before construction (script tag usage)

```js
// runtime-config.js served by your host at request time
globalThis.__SAFE_SDK_CONFIG__ = {
  baseUrl: 'https://gatekeeper.bespot.dev/v2',
  apiKey: 'your-api-key',
  applicationId: 'your-app-id',
  applicationVersion: 'your-app-version',
}
```

```html
<script src="./runtime-config.js"></script>
<script src="./safe-sdk.umd.min.js"></script>
<script>
  const sdk = new SafeSDK()
  sdk.initialize(jwt)
</script>
```

Constructor argument wins when both are present. Missing or blank fields throw `Failure.InvalidSDKConfiguration`.

`SafeSDK` is a **singleton** — repeated `new SafeSDK()` returns the same instance.

## API

### `sdk.initialize(jwt: string): Promise<void>`

Runs the one-time device registration and stores the JWT. Must complete before `check()` is usable.

### `sdk.check(): Promise<CheckResult | Failure>`

Runs an anti-fraud check. Returns a `CheckResult` on success or a `Failure.*` instance on failure (does not throw).

```ts
const result = await sdk.check()
if (result instanceof Error) {
  // handle failure
}
```

### `sdk.subscribe(): void`

Starts periodic checks. Interval is set server-side via the register response; falls back to 15 minutes if unset. Access the last outcome via `sdk.lastCheckResult`.

### `sdk.unsubscribe(): void`

Stops periodic checks.

### `sdk.setAccessToken(jwt: string): void`

Rotates the JWT without re-registering the device. Use when your auth layer issues a fresh token.

Throws `Failure.InvalidAccessToken` (empty/whitespace) or `Failure.InvalidAccessTokenFormat` (not `header.payload.signature`).

### `sdk.setUserId(id: string): void`

Sets the `X-UserId` header on all subsequent requests. Optional.

### `sdk.lastCheckResult`

Read-only. The outcome of the most recent `check()` call, or `undefined` before the first check.

## Token Rotation

### Proactive (recommended)

```ts
authClient.on('tokenWillExpire', async () => {
  const fresh = await authClient.refresh()
  sdk.setAccessToken(fresh)
})
```

### Reactive

```ts
const result = await sdk.check()
if (result instanceof Error && result.name === 'AuthenticationFailed') {
  const fresh = await authClient.refresh()
  sdk.setAccessToken(fresh)
  void sdk.check() // optional immediate retry
}
```

## Failure Types

All failures are instances of `Error` with a typed `name` property.

| Name | Meaning |
|------|---------|
| `InvalidSDKConfiguration` | Runtime config missing or invalid |
| `InvalidApiKey` | API key missing, disabled, or invalid |
| `InvalidAccessToken` | JWT empty or whitespace |
| `InvalidAccessTokenFormat` | JWT not in `header.payload.signature` format |
| `AuthenticationFailed` | Authentication failed |
| `AuthorizationFailed` | Authorization failed |
| `NotInitialized` | `initialize()` not yet completed |
| `GeolocationNotSupported` | Browser geolocation API unavailable |
| `NoRecipeFound` | No recipe configured for this application |
| `NoCheckFound` | No check configured for this application |
| `InvalidResponseError` | Server response malformed |
| `NetworkError` | Request could not reach the server (includes timeout) |
| `ServerError` | Server returned an error response |
| `StorageUnavailable` | Device ID could not be persisted in this browser |
| `UnknownError` | Unexpected error; contact support |

```ts
import { Failure } from '@bespot/gatekeeper-web-sdk'

const result = await sdk.check()
if (result instanceof Failure.NetworkError) {
  // retry later
}
```

## Security

`apiKey` is a publishable identifier — it will be visible in DevTools and your page source. Do not treat it as a secret. Server-side rate-limiting by key is the intended protection model. Use `initialize(jwt)` for authentication.

## Browser Support

Targets modern browsers with ES2020+ support. Requires `fetch`, `crypto.subtle`, and `TextEncoder`.
