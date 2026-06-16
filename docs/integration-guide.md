# Bespot Gatekeeper Web SDK — Integration Guide

This guide explains how to add the Gatekeeper Web SDK to your website. You do **not** need Node.js, npm, or a build step. You download a pre-built package, host two JavaScript files, configure four settings, pass a JWT, and call the SDK API.

## Table of Contents

1. [Overview](#1-overview)
2. [Bespot prerequisites](#2-bespot-prerequisites)
3. [SDK package installation](#3-sdk-package-installation)
4. [Distribution format selection](#4-distribution-format-selection)
5. [Runtime configuration](#5-runtime-configuration)
6. [JWT access token requirements](#6-jwt-access-token-requirements)
7. [Integration sequence](#7-integration-sequence)
8. [Integration examples](#8-integration-examples)
9. [API reference](#9-api-reference)
10. [Error handling](#10-error-handling)
11. [Geolocation](#11-geolocation)
12. [Access token rotation](#12-access-token-rotation)
13. [Common integration mistakes](#13-common-integration-mistakes)
14. [Troubleshooting](#14-troubleshooting)
15. [Security](#15-security)
16. [SDK version upgrades](#16-sdk-version-upgrades)
17. [Support](#17-support)

---

## 1. Overview

The Gatekeeper Web SDK runs in the user's browser. It:

1. **Registers** the browser as a device (once, on first successful `initialize`).
2. **Runs checks** against the Gatekeeper backend and returns an `action` and `ticket` you can use in your application logic.

Typical flow:

```text
Your page loads SDK → you pass config + JWT → initialize() → check() → you read action/ticket
```

The SDK is a **single class** named `SafeSDK`. It is a **singleton**: every `new SafeSDK()` in the same page returns the same instance.

### What the SDK does **not** do

| Misconception | Reality |
|---------------|---------|
| "I set credentials in a `.env` file and the bundle reads them." | **Wrong.** The JavaScript bundle contains **no** API key, application ID, or backend URL. You must supply them in your page or a config script at runtime. |
| "I can put `client_secret` in frontend code to get a JWT." | **Wrong.** OAuth secrets belong on **your server** only. The browser receives a short-lived JWT from your backend. |
| "`check()` throws when something fails." | **Wrong.** `check()` **returns** an `Error` object on failure. Only `initialize()` **throws**. |
| "I can call `check()` before `initialize()`." | **Wrong.** `check()` returns `NotInitialized` until `initialize()` completes successfully. |

---

## 2. Bespot prerequisites

Before writing code, collect these values from Bespot (dashboard or your account team):

| Name | Used as | Example | Where it goes |
|------|---------|---------|---------------|
| **API key** | `apiKey` | `13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs` | Runtime config (browser) |
| **Application ID** | `applicationId` | `mywebapp.mycompany.com` | Runtime config (browser) |
| **Application version** | `applicationVersion` | `1.0.0` | Runtime config (browser) — **your app release**, not the SDK tarball version |
| **Gatekeeper base URL** | `baseUrl` | `https://gatekeeper.bespot.dev/v2` | Runtime config (browser) — **no trailing slash** |
| **JWT access token** | argument to `initialize()` | `eyJhbGciOi...` | Fetched at runtime from **your backend** |

### Backend-only credentials (for JWT issuance — not in the browser)

Your server uses these to call the auth issuer. The browser never sees `client_secret`.

| Name | Purpose |
|------|---------|
| `AUTH_SERVER_URL` | Auth issuer base URL (e.g. `https://gatekeeper.auth.eu-west-1.amazoncognito.com`) |
| `CLIENT_ID` | OAuth client id |
| `CLIENT_SECRET` | OAuth client secret — **server only** |
| `SCOPE` | OAuth scope (e.g. `main_antifraud_resource_server/public`) |

The **API key** (`apiKey` in SDK config) is sent on **Gatekeeper** requests (`x-api-key` header). It is separate from the OAuth token exchange unless your auth setup explicitly requires otherwise.

### Environment requirements

- **HTTPS** in production (required for geolocation and device persistence).
- **CORS**: the Gatekeeper `baseUrl` must accept browser requests from your site's origin.
- **Geolocation**: the browser may show a permission prompt during checks. If the user denies location, the check can still complete (see [§11](#11-geolocation)).

---

## 3. SDK package installation

### Where to download

Get a versioned package from this repository under `packages/`:

```text
gatekeeper-web-sdk-{version}.tgz
```

Example: `gatekeeper-web-sdk-1.0.0.tgz`

### Extract the package

```bash
tar -xzf gatekeeper-web-sdk-1.0.0.tgz
```

After extraction you will have **exactly this layout**:

```text
sdk/
  safe-sdk.esm.min.js
  safe-sdk.umd.min.js
```

These are the only files you need from the package.

### Host the files

Copy the `sdk/` folder (or its contents) to your CDN or web server, for example:

```text
https://your-cdn.example.com/sdk/safe-sdk.esm.min.js
https://your-cdn.example.com/sdk/safe-sdk.umd.min.js
```

Use the URL paths in your HTML or bundler imports. The filenames are always `safe-sdk.esm.min.js` and `safe-sdk.umd.min.js` — not `gatekeeper.*`.

---

## 4. Distribution format selection

You need **one** of the two files, not both on the same page (unless you are testing).

| File | Choose when | How you load it |
|------|-------------|-----------------|
| `safe-sdk.esm.min.js` | Your app uses ES modules (`import`), or a bundler (Vite, Webpack, React, Vue, Angular) | `<script type="module">` with `import SafeSDK from '...'` |
| `safe-sdk.umd.min.js` | Plain HTML with classic `<script src="...">` tags | `<script src="...">` then `new window.SafeSDK()` |

Both files expose the same API. The class name is always **`SafeSDK`**.

---

## 5. Runtime configuration

The SDK needs **four non-empty strings** before it can talk to Gatekeeper. If any value is missing or blank, construction throws an error named `InvalidSDKConfiguration`.

| Field | Description |
|-------|-------------|
| `baseUrl` | Gatekeeper API root (no `/` at the end) |
| `apiKey` | Your Bespot API key |
| `applicationId` | Your site domain name - treated as application identifier in Bespot |
| `applicationVersion` | Your application's release label in Bespot (e.g. `1.0.0`) |

### Option A — pass config to the constructor (recommended)

```js
const sdk = new SafeSDK({
  baseUrl: 'https://gatekeeper.bespot.dev/v2',
  apiKey: '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs',
  applicationId: 'mywebapp.mycompany.com',
  applicationVersion: '1.2.0',
})
```

### Option B — set a global, then call `new SafeSDK()` with no arguments

Load a small script **before** the SDK bundle:

**`runtime-config.js`** (you host this file; values come from your deployment environment):

```js
globalThis.__SAFE_SDK_CONFIG__ = {
  baseUrl: 'https://gatekeeper.bespot.dev/v2',
  apiKey: '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs',
  applicationId: 'mywebapp.mycompany.com',
  applicationVersion: '1.2.0',
}
```

**HTML load order:**

```html
<script src="/runtime-config.js"></script>
<script src="/sdk/safe-sdk.umd.min.js"></script>
<script>
  const sdk = new SafeSDK() // reads globalThis.__SAFE_SDK_CONFIG__
</script>
```

If you use Option B with ESM, still set `globalThis.__SAFE_SDK_CONFIG__` in an earlier classic script, then `import SafeSDK` and `new SafeSDK()`.

### Important notes

- **Do not commit** real API keys or tokens to git. Generate `runtime-config.js` in your deployment pipeline or serve it from a server that injects environment values.
- The SDK bundle is the **same for every customer**. Nothing is "baked in" at download time.
- Calling `new SafeSDK(newConfig)` again on the same page **updates** config on the existing singleton instance.

---

## 6. JWT access token requirements

`initialize()` requires a **JWT** string in the format `header.payload.signature` (three parts separated by dots).

The SDK checks that the string **looks like** a JWT. It does **not** replace your auth server. Gatekeeper validates expiry and claims when you call `initialize` and `check`.

### Correct pattern: your backend issues the token

```text
Browser  →  GET /api/your-gatekeeper-token  →  Your server
Your server  →  POST /oauth2/token (with client_secret)  →  Auth server
Your server  →  returns access_token  →  Browser
Browser  →  sdk.initialize(access_token)
```

**Never** put `client_secret` in browser JavaScript.

### Reference: server-side token request (your backend only)

Your server performs this call (integrators implement this on the server, not in the page):

```http
POST {AUTH_SERVER_URL}/oauth2/token
Content-Type: application/x-www-form-urlencoded
Authorization: Basic Base64(client_id:client_secret)

grant_type=client_credentials&scope={SCOPE}
```

Example response:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_in": 86400,
  "token_type": "Bearer"
}
```

| Field | Meaning |
|-------|---------|
| `access_token` | JWT string — pass this to `sdk.initialize()` or `sdk.setAccessToken()` |
| `expires_in` | Token lifetime in **seconds** — schedule refresh before expiry (see [§12](#12-access-token-rotation)) |
| `token_type` | Always `Bearer` — the SDK sends `Authorization: Bearer {access_token}` on Gatekeeper calls |

Send only `access_token` to the browser. Then:

```js
await sdk.initialize(access_token)
```

Full authentication documentation: [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

---

## 7. Integration sequence

Follow this sequence **every time** you integrate:

| Step | Action | Required? | On failure |
|------|--------|-----------|------------|
| 1 | Create `SafeSDK` with runtime config | Yes | **Throws** `InvalidSDKConfiguration` |
| 2 | `await sdk.initialize(jwt)` | Yes | **Throws** (e.g. `InvalidAccessToken`, `NetworkError`, `AuthenticationFailed`) |
| 3 | `sdk.setUserId(id)` | No | — |
| 4 | `await sdk.check()` | When you need a result | **Returns** success object or `Error` (does not throw) |
| 5 | `sdk.subscribe(ms, callback)` | No | **Throws** only if interval is invalid |
| 6 | `sdk.unsubscribe()` | When stopping periodic checks | — |

```text
new SafeSDK(config)
       ↓
await initialize(jwt)     ← must succeed before any check
       ↓
setUserId(...)            ← optional
       ↓
await check()             ← one-time check
       ↓
subscribe(30000, ...)     ← optional; interval in MILLISECONDS
       ↓
unsubscribe()             ← when done
```

### What `initialize` does

On first successful `initialize` in a browser profile, the SDK:

1. Sends device information to `POST {baseUrl}/device/{applicationId}/{applicationVersion}/register`
2. Stores a device id locally for later checks
3. Caches check definitions from the server

You do **not** call `initialize` again when the JWT expires. Use `setAccessToken` instead ([§12](#12-access-token-rotation)).

### What `check` returns on success

```js
{
  action: '...',      // string from Gatekeeper
  ticket: '...',      // string from Gatekeeper
  timestamp: 1710000000000  // number, milliseconds since epoch
}
```

---

## 8. Integration examples

Replace placeholder URLs and credentials with your real values. Copy-ready files: [../templates/](../templates/).

### ESM example (`safe-sdk.esm.min.js`)

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Gatekeeper SDK — ESM</title>
  </head>
  <body>
    <script type="module">
      import SafeSDK from '/sdk/safe-sdk.esm.min.js'

      const sdk = new SafeSDK({
        baseUrl: 'https://gatekeeper.bespot.dev/v2',
        apiKey: '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs',
        applicationId: 'mywebapp.mycompany.com',
        applicationVersion: '1.0.0',
      })

      async function startGatekeeper() {
        try {
          // Step 1: Get JWT from YOUR backend (never use client_secret in the browser)
          const response = await fetch('/api/gatekeeper-token')
          if (!response.ok) {
            throw new Error('Could not fetch Gatekeeper token from backend')
          }
          const jwt = (await response.text()).trim()
          if (!jwt) {
            throw new Error('Backend returned an empty token')
          }

          // Step 2: Initialize (required) — throws on failure
          await sdk.initialize(jwt)

          // Step 3: Optional user id (sent as X-UserId header)
          sdk.setUserId('client-user-123')

          // Step 4: One check — returns result or Error (does not throw)
          const result = await sdk.check()
          if (result instanceof Error) {
            console.error('[CHECK FAILED]', result.name, '-', result.message)
            return
          }
          console.log('[CHECK OK]', {
            action: result.action,
            ticket: result.ticket,
            timestamp: result.timestamp,
          })

          // Step 5: Periodic checks every 30 seconds (30000 milliseconds)
          sdk.subscribe(
            30000,
            (periodicResult) => {
              if (periodicResult instanceof Error) {
                console.error(
                  '[PERIODIC FAILED]',
                  periodicResult.name,
                  '-',
                  periodicResult.message,
                )
                return
              }
              console.log('[PERIODIC OK]', {
                action: periodicResult.action,
                ticket: periodicResult.ticket,
              })
            },
            (callbackError) => {
              // Optional: your callback threw or rejected
              console.error('[CALLBACK ERROR]', callbackError)
            },
          )

          // Step 6: Later, when you want to stop:
          // sdk.unsubscribe()
        } catch (error) {
          const err = error instanceof Error ? error : new Error(String(error))
          console.error('[INITIALIZE FAILED]', err.name, '-', err.message)
        }
      }

      startGatekeeper()
    </script>
  </body>
</html>
```

### UMD example (`safe-sdk.umd.min.js`)

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Gatekeeper SDK — UMD</title>
  </head>
  <body>
  <!-- Step 0: Runtime config BEFORE the SDK script -->
  <script>
    globalThis.__SAFE_SDK_CONFIG__ = {
      baseUrl: 'https://gatekeeper.bespot.dev/v2',
      apiKey: '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs',
      applicationId: 'mywebapp.mycompany.com',
      applicationVersion: '1.0.0',
    }
  </script>
  <script src="/sdk/safe-sdk.umd.min.js"></script>
  <script>
    ;(async function startGatekeeper() {
      const sdk = new window.SafeSDK()

      try {
        const response = await fetch('/api/gatekeeper-token')
        if (!response.ok) {
          throw new Error('Could not fetch Gatekeeper token from backend')
        }
        const jwt = (await response.text()).trim()
        if (!jwt) {
          throw new Error('Backend returned an empty token')
        }

        await sdk.initialize(jwt)

        sdk.setUserId('client-user-123')

        const result = await sdk.check()
        if (result instanceof Error) {
          console.error('[CHECK FAILED]', result.name, '-', result.message)
          return
        }
        console.log('[CHECK OK]', {
          action: result.action,
          ticket: result.ticket,
        })

        sdk.subscribe(30000, function (periodicResult) {
          if (periodicResult instanceof Error) {
            console.error(
              '[PERIODIC FAILED]',
              periodicResult.name,
              '-',
              periodicResult.message,
            )
            return
          }
          console.log('[PERIODIC OK]', {
            action: periodicResult.action,
            ticket: periodicResult.ticket,
          })
        })
      } catch (error) {
        const err = error instanceof Error ? error : new Error(String(error))
        console.error('[INITIALIZE FAILED]', err.name, '-', err.message)
      }
    })()
  </script>
  </body>
</html>
```

---

## 9. API reference

### Constructor

```ts
new SafeSDK(config?: {
  baseUrl: string
  apiKey: string
  applicationId: string
  applicationVersion: string
})
```

All four fields are required (non-empty strings) whether passed here or via `globalThis.__SAFE_SDK_CONFIG__`.

### Methods

| Method | Throws? | Description |
|--------|---------|-------------|
| `initialize(accessToken: string): Promise<void>` | **Yes** | Validates JWT shape, registers device with Gatekeeper. **Must succeed before `check`.** |
| `setAccessToken(accessToken: string): void` | **Yes** | Updates JWT **without** re-registering. Use after JWT refresh. Does **not** replace `initialize`. |
| `setUserId(userId: string): void` | No | Sets `X-UserId` request header on later calls. |
| `check(): Promise<CheckResult>` | No | Runs one Gatekeeper check. Returns success object or `Error`. |
| `subscribe(intervalMs, callback?, onPeriodicCallbackError?): Promise<void>` | **Yes** if `intervalMs` is not a positive finite number | Runs `check()` on a timer. **`intervalMs` is milliseconds** (e.g. `30000` = 30 seconds). Pauses while browser tab is hidden. |
| `unsubscribe(): void` | No | Stops periodic checks and clears timers. |

### Properties and helpers

| Member | Description |
|--------|-------------|
| `applicationVersion` | The `applicationVersion` you configured |
| `userId` | Current user id from `setUserId`, or `''` |
| `isConfigured` | Whether config and session context exist |
| `result` | Last **successful** `check()` result, or `undefined` |
| `getLastGeolocationFailure()` | After `check()`, reason geo was empty (see [§11](#11-geolocation)) |
| `getDeviceSeed(): Promise<string>` | Device fingerprint hash (debugging only) |

### HTTP calls the SDK makes

| When | Request |
|------|---------|
| `initialize()` | `POST {baseUrl}/device/{applicationId}/{applicationVersion}/register` |
| `check()` | `POST {baseUrl}/device/{applicationId}/{applicationVersion}/check` |

Request headers include:

- `x-api-key` — your API key
- `Authorization: Bearer {jwt}` — access token
- `X-DeviceId` — after successful register (on check)
- `X-UserId` — if you called `setUserId`
- `x-devicelastlocation` — geolocation payload on check

---

## 10. Error handling

There are **two different** error behaviors. Mixing them up is the most common integration bug.

### Rule 1: `initialize` and `setAccessToken` **throw**

Always wrap in `try/catch`:

```js
try {
  await sdk.initialize(jwt)
} catch (error) {
  console.error('Initialize failed:', error.name, error.message)
}
```

### Rule 2: `check` **returns** an error — it does **not** throw

Always use `instanceof Error`:

```js
const result = await sdk.check()
if (result instanceof Error) {
  console.error('Check failed:', result.name, result.message)
} else {
  console.log('Check succeeded:', result.action, result.ticket)
}
```

The same applies to the value passed to your `subscribe` callback.

### Error reference

See [error-reference.md](error-reference.md) for the full catalog, geolocation codes, and legacy name mapping.

When logging errors, use **`error.name`** and **`error.message`**.

| `error.name` | Meaning | Typical fix |
|--------------|---------|-------------|
| `InvalidSDKConfiguration` | Missing or empty `baseUrl`, `apiKey`, `applicationId`, or `applicationVersion` | Set all four config fields before `new SafeSDK()` |
| `InvalidAccessToken` | JWT is empty or only whitespace | Pass a non-empty token to `initialize` |
| `InvalidAccessTokenFormat` | JWT is not `xxx.yyy.zzz` (three non-empty parts) | Fix token format from your auth server |
| `NotInitialized` | `check()` called before successful `initialize`, or only `setAccessToken` was called | Call `await initialize(jwt)` first |
| `InvalidApiKey` | Gatekeeper rejected the API key | Verify `apiKey` with Bespot |
| `AuthenticationFailed` | HTTP 401 from Gatekeeper | JWT expired or invalid — refresh token ([§12](#12-access-token-rotation)) |
| `AuthorizationFailed` | HTTP 403 from Gatekeeper | JWT or app lacks permission |
| `GeolocationNotSupported` | Browser has no Geolocation API | Use a supported browser; cannot recover on that client |
| `NoRecipeFound` | No backend recipe for your app config | Contact Bespot with `applicationId` + `applicationVersion` |
| `NoCheckFound` | No checks available for your app | Contact Bespot with `applicationId` + `applicationVersion` |
| `NetworkError` | Browser could not reach Gatekeeper (`fetch` failed) | Check network, `baseUrl`, CORS, HTTPS |
| `ServerError` | Gatekeeper returned HTTP 5xx | Retry later; contact Bespot if persistent |
| `InvalidResponseError` | Response body was missing required fields | Contact Bespot if persistent |
| `StorageUnavailable` | Device id could not be saved in the browser | User privacy settings / blocked storage |
| `UnknownError` | Unclassified failure | Log `error.message`; contact support |

---

## 11. Geolocation

Each `check()` tries to read the browser location.

| User / browser situation | Does `check()` still run? | How to detect |
|--------------------------|---------------------------|---------------|
| User allows location | Yes, with coordinates | `getLastGeolocationFailure()` returns `null` |
| User denies permission | **Yes**, with empty location | `geoapi_permission_denied` |
| Position unavailable | **Yes** | `geoapi_position_unavailable` |
| Timeout | **Yes** | `geoapi_timeout` |
| Geolocation API missing | **No** — `check()` returns `GeolocationNotSupported` | `geoapi_unavailable` |

Example:

```js
const result = await sdk.check()
if (result instanceof Error) {
  // handle check failure
} else {
  const geoIssue = sdk.getLastGeolocationFailure()
  if (geoIssue) {
    console.warn('Check ran but location was not available:', geoIssue)
  }
}
```

Denied geolocation does **not** stop the check. Only a missing Geolocation API returns a hard failure.

---

## 12. Access token rotation

JWTs expire. After the **first** successful `initialize`, refresh the token with `setAccessToken` — **do not** call `initialize` again just to rotate the JWT.

```js
// After initialize() succeeded once:
sdk.setAccessToken(freshJwtFromYourBackend)
```

| Method | Registers device again? | When to use |
|--------|-------------------------|-------------|
| `initialize(jwt)` | **Yes** (first time in this browser profile) | Once at session start |
| `setAccessToken(jwt)` | **No** | Every time you get a new JWT from your backend |

### Proactive refresh (recommended)

```js
// When your auth layer knows the token will expire soon:
const fresh = await fetch('/api/gatekeeper-token').then((r) => r.text())
sdk.setAccessToken(fresh.trim())
```

### Reactive refresh (if a check fails with AuthenticationFailed)

```js
sdk.subscribe(60000, async (result) => {
  if (result instanceof Error && result.name === 'AuthenticationFailed') {
    const fresh = await fetch('/api/gatekeeper-token').then((r) => r.text())
    sdk.setAccessToken(fresh.trim())
    await sdk.check() // optional immediate retry
    return
  }
  // handle success...
})
```

**Note:** If a `check()` is already in flight when you call `setAccessToken`, that request keeps the old token. The new token applies to the **next** call.

---

## 13. Common integration mistakes

| Mistake | What happens | What to do instead |
|---------|--------------|-------------------|
| Calling `check()` before `await initialize()` | `NotInitialized` | Always `initialize` first |
| Using `try/catch` around `check()` only | Missed failures | Use `if (result instanceof Error)` |
| Passing `30` to `subscribe` expecting 30 seconds | Checks every 30 ms | Pass **milliseconds**: `30000` for 30 seconds |
| Using SDK tarball version as `applicationVersion` | `NoRecipeFound` or auth errors | Use the app version registered with Bespot |
| Trailing slash on `baseUrl` | May cause bad URLs | Use `https://host/v2` not `https://host/v2/` |
| Putting `client_secret` in frontend | Security risk | Token exchange on your server only |
| Calling `initialize()` on every JWT refresh | Unnecessary re-registration | Use `setAccessToken()` after the first `initialize()` |
| Loading UMD script before `__SAFE_SDK_CONFIG__` | `InvalidSDKConfiguration` | Config script must run **first** |
| Expecting `.env` in the tarball to configure production | Nothing happens | Set runtime config in your host page or `runtime-config.js` |

---

## 14. Troubleshooting

### `initialize` throws immediately

1. JWT is a non-empty string with exactly two dots (three segments).
2. All four config fields are set and non-empty.
3. JWT is not expired (get a fresh one from your backend).
4. Browser can reach `baseUrl` (open DevTools → Network tab).
5. CORS allows your site's origin on Gatekeeper responses.

### `check` returns `InvalidApiKey` or `AuthenticationFailed`

1. Confirm `apiKey`, `applicationId`, and `applicationVersion` match Bespot's records.
2. Confirm JWT was issued for the correct resource/scope.
3. If token may be expired, refresh with `setAccessToken`.

### `check` returns `NetworkError`

1. User is offline or behind a blocking proxy.
2. `baseUrl` is wrong or unreachable from the user's network.
3. Mixed content: HTTPS page calling HTTP API (blocked by browser).

### No periodic check results appear

1. `subscribe()` must be called **after** `initialize()` succeeds (wrap `initialize` in `try/catch` and only subscribe in the success path).
2. Your callback must handle failures with `instanceof Error` — silent callbacks look like “no results”.
3. Confirm you did not call `unsubscribe()` earlier on the same page.
4. Confirm `intervalMs` is in **milliseconds** (`30000` for 30 seconds, not `30`).

### Periodic checks seem to stop or slow down

1. The SDK **pauses** the timer while the tab is **hidden** and resumes when visible — this is intentional.
2. Confirm you did not call `unsubscribe()`.
3. Confirm `intervalMs` is a positive number in **milliseconds**.

### `StorageUnavailable` on `initialize`

1. Browser blocks cookies/storage (private mode, strict tracking protection).
2. Ask user to allow site data or retry in a normal window.

---

## 15. Security

- **Never** commit `.env` files, API keys, JWTs, or `client_secret` to source control.
- **Never** run OAuth client-credentials with `client_secret` in browser code.
- **Never** expose long-lived secrets in frontend code.
- Issue **short-lived** JWTs from your backend; rotate with `setAccessToken`.
- **Rotate credentials** (API keys, client secrets) on a regular schedule per your security policy.
- Store production secrets in a **secret manager** or CI/CD vault; inject into `runtime-config.js` or your backend at deploy time — not in the static SDK bundle.
- Serve SDK files and config over **HTTPS** in all environments.
- The API key is sent from the browser (`x-api-key` header). Treat it as a client-scoped credential with permissions defined by Bespot.
- Do not log full JWTs in analytics or error reporting.

---

## 16. SDK version upgrades

To upgrade the SDK package:

1. Download the newer `gatekeeper-web-sdk-X.Y.Z.tgz`.
2. Extract and replace hosted `sdk/safe-sdk.*.min.js` files (or pin a new CDN path).
3. Re-test `initialize` → `check` → `subscribe` in staging.
4. Read the changelog for that release before deploying to production.

Upgrading the SDK tarball does **not** change your `applicationVersion` config field unless **you** choose to.

---

## 17. Support

When contacting Bespot support, include:

- SDK package version (e.g. `gatekeeper-web-sdk-1.0.0.tgz` → `1.0.0`)
- `applicationId` and `applicationVersion` from your config
- `error.name` and `error.message`
- Whether the problem occurs on `initialize` or `check`
- Browser name, version, and operating system
- Approximate time (UTC) of the failure

Authentication reference: [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

---
