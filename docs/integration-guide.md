# Bespot Gatekeeper Web SDK — Integration Guide

This guide explains how to add the Gatekeeper Web SDK to your web application. You do **not** need Node.js, npm, or a build step. You download a pre-built package, host two JavaScript files, configure four settings, pass a JWT, and call the SDK API.

## Table of Contents

1. [Overview](#1-overview)
2. [Bespot prerequisites](#2-bespot-prerequisites)
3. [SDK package installation](#3-sdk-package-installation)
4. [Distribution format selection](#4-distribution-format-selection)
5. [Runtime configuration](#5-runtime-configuration)
6. [Integration sequence](#6-integration-sequence)
7. [Integration examples](#7-integration-examples)
8. [API reference](#8-api-reference)
9. [Error handling](#9-error-handling)
10. [Geolocation](#10-geolocation)
11. [Access token rotation](#11-access-token-rotation)
12. [Common integration mistakes](#12-common-integration-mistakes)
13. [Troubleshooting](#13-troubleshooting)
14. [Security](#14-security)
15. [SDK version upgrades](#15-sdk-version-upgrades)
16. [Support](#16-support)

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

Before writing code, sign up at **[gatekeeper.bespot.com](https://gatekeeper.bespot.com)** to create your account and obtain credentials.

| What | URL / value | Purpose |
|------|-------------|---------|
| Account portal | [gatekeeper.bespot.com](https://gatekeeper.bespot.com) | Sign in and manage your Bespot account |
| Gatekeeper API (`baseUrl`) | `bespot-gatekeeper-base-url` (e.g. `https://gatekeeper.bespotcompany.com`) | API host Bespot assigns when you register — set this in SDK runtime config |
| Product documentation | [docs.bespot.com](https://docs.bespot.com) | Official Bespot guides and API reference |

Do **not** use the account portal URL as `baseUrl`. The SDK must call your assigned Gatekeeper API host, not the sign-in site.

Collect these values:

| Name | Used as | Example | Where it goes |
|------|---------|---------|---------------|
| **API key** | `apiKey` | `your-api-key` (e.g. `13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs`) | Runtime config (browser) |
| **Application ID** | `applicationId` | `your-app-id` (e.g. `mywebapp.mycompany.com`) | Runtime config (browser) |
| **Application version** | `applicationVersion` | `your-app-version` (e.g. `2.4.1`) | Runtime config (browser) — **your app release**, not the SDK tarball version |
| **Gatekeeper base URL** | `baseUrl` | `bespot-gatekeeper-base-url` (e.g. `https://gatekeeper.bespotcompany.com`) | Runtime config (browser)|
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
- **CORS**: the Gatekeeper `baseUrl` must accept browser requests from your site's origin. Allowlisting is configured by Bespot. If DevTools shows a CORS error on requests to `baseUrl`, see [§13](#cors-errors-in-the-browser).
- **Geolocation**: the SDK needs browser location permission to obtain the user's position. Tell your users why location is required; if they deny permission, location-dependent checks will not work (see [§10](#10-geolocation)).

---

## 3. SDK package installation

### Option A — npm (recommended for module bundlers)

```bash
npm install @bespot/gatekeeper-web-sdk
```

```js
import SafeSDK from '@bespot/gatekeeper-web-sdk'
```

### Option B — CDN / self-hosted (no build step)

Download the latest versioned bundles from [GitHub Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases):

- `safe-sdk.esm.min.js` — ES module format
- `safe-sdk.umd.min.js` — UMD format (classic script tags)

Copy the downloaded file(s) to your CDN or web server, for example:

```text
https://your-cdn.example.com/sdk/safe-sdk.esm.min.js
https://your-cdn.example.com/sdk/safe-sdk.umd.min.js
```

The filenames are always `safe-sdk.esm.min.js` and `safe-sdk.umd.min.js`.

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
| `baseUrl` | Gatekeeper API root (no `/` at the end). Sample: `bespot-gatekeeper-base-url` (e.g. `https://gatekeeper.bespotcompany.com`) |
| `apiKey` | Your Bespot API key. Sample: `your-api-key` (e.g. `13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs`) |
| `applicationId` | Your site domain — application identifier in Bespot. Sample: `your-app-id` (e.g. `mywebapp.mycompany.com`) |
| `applicationVersion` | Your application's release label in Bespot. Sample: `your-app-version` (e.g. `2.4.1`) |

### Option A — pass config to the constructor (recommended)

```js
const sdk = new SafeSDK({
  baseUrl: 'bespot-gatekeeper-base-url', // e.g. 'https://gatekeeper.bespotcompany.com'
  apiKey: 'your-api-key', // e.g. '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs'
  applicationId: 'your-app-id', // e.g. 'mywebapp.mycompany.com'
  applicationVersion: 'your-app-version', // e.g. '2.4.1'
})
```

### Option B — set a global, then call `new SafeSDK()` with no arguments

Load a small script **before** the SDK bundle:

**`runtime-config.js`** (you host this file; values come from your deployment environment):

```js
globalThis.__SAFE_SDK_CONFIG__ = {
  baseUrl: 'bespot-gatekeeper-base-url', // e.g. 'https://gatekeeper.bespotcompany.com'
  apiKey: 'your-api-key', // e.g. '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs'
  applicationId: 'your-app-id', // e.g. 'mywebapp.mycompany.com'
  applicationVersion: 'your-app-version', // e.g. '2.4.1'
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
- Calling `new SafeSDK(newConfig)` again on the same page **updates** config on the existing singleton instance.

---

## 6. Integration sequence

Follow this sequence **every time** you integrate:

| Step | Action | Required? | On failure |
|------|--------|-----------|------------|
| 1 | Create `SafeSDK` with runtime config | Yes | **Throws** `InvalidSDKConfiguration` |
| 2 | `await sdk.initialize(jwt)` | Yes | **Throws** (e.g. `InvalidAccessToken`, `NetworkError`, `AuthenticationFailed`) |
| 3 | `sdk.setUserId(id)` | No | — |
| 4 | `await sdk.check()` | When you need a result | **Returns** success object or `Error` (does not throw) |
| 5 | `await sdk.subscribe()` | No | Interval from [server configuration](#periodic-checks) |
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
await subscribe()         ← optional
       ↓
unsubscribe()             ← when done
```

---

## 7. Integration examples

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
        baseUrl: 'bespot-gatekeeper-base-url', // e.g. 'https://gatekeeper.bespotcompany.com'
        apiKey: 'your-api-key', // e.g. '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs'
        applicationId: 'your-app-id', // e.g. 'mywebapp.mycompany.com'
        applicationVersion: 'your-app-version', // e.g. '2.4.1'
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

          // Step 5: Start periodic checks (interval configured server-side by Bespot)
          await sdk.subscribe()

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
      baseUrl: 'bespot-gatekeeper-base-url', // e.g. 'https://gatekeeper.bespotcompany.com'
      apiKey: 'your-api-key', // e.g. '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs'
      applicationId: 'your-app-id', // e.g. 'mywebapp.mycompany.com'
      applicationVersion: 'your-app-version', // e.g. '2.4.1'
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

        await sdk.subscribe()
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

## 8. API reference

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
| `setUserId(userId: string): void` | No | Sets your customer/client related unique user identifier |
| `check()` | No | Runs one Gatekeeper check. Returns a [check result](integration-guide.md#check-result-shape) object or an `Error` subclass (does not throw). |
| `subscribe(): Promise<void>` | No | Starts periodic checks on the [registration interval](#periodic-checks). Pauses while browser tab is hidden. |
| `unsubscribe(): void` | No | Stops periodic checks and clears timers. |

### Properties

| Member | Description |
|--------|-------------|
| `applicationId` | The `applicationId` you configured |
| `applicationVersion` | The `applicationVersion` you configured |
| `userId` | Current user id from `setUserId`, or `''` |
| `lastCheckResult` | Last `check()` outcome — [check result](#check-result-shape) object or `Error` subclass, or `undefined` before the first check |

### Check result shape

When `check()` succeeds, it returns a plain object (not an `Error`):

| Field | Type | Description |
|-------|------|-------------|
| `action` | `string` | Gatekeeper decision for your application logic (allowed values depend on your Bespot configuration) |
| `ticket` | `string` | Opaque ticket for this check — use per your integration agreement with Bespot |
| `timestamp` | `number` | Unix time in **milliseconds** when the result was recorded client-side |

```js
const result = await sdk.check()
if (!(result instanceof Error)) {
  console.log(result.action, result.ticket, result.timestamp)
}
```

### Periodic checks

`subscribe()` runs `check()` on a fixed interval. The interval is **not** passed as a JavaScript argument.

The interval is set by Bespot in `configuration.periodic_interval` from device registration (string or number, in **milliseconds**).

Call `subscribe()` with **no arguments** after a successful `initialize()`. Read `sdk.lastCheckResult` after each periodic run.

---

## 9. Error handling

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

### Error reference

See [error-reference.md](error-reference.md) for the full catalog.

When logging errors, use **`error.name`** and **`error.message`**.

| `error.name` | Meaning | Typical fix |
|--------------|---------|-------------|
| `InvalidSDKConfiguration` | Missing or empty `baseUrl`, `apiKey`, `applicationId`, or `applicationVersion` | Set all four config fields before `new SafeSDK()` |
| `InvalidAccessToken` | JWT is empty or only whitespace | Pass a non-empty token to `initialize` |
| `InvalidAccessTokenFormat` | JWT is not `xxx.yyy.zzz` (three non-empty parts) | Fix token format from your auth server |
| `NotInitialized` | `check()` called before successful `initialize`, or only `setAccessToken` was called | Call `await initialize(jwt)` first |
| `InvalidApiKey` | Gatekeeper rejected the API key | Verify `apiKey` with Bespot |
| `AuthenticationFailed` | HTTP 401 from Gatekeeper | JWT expired or invalid — refresh token ([§11](#11-access-token-rotation)) |
| `AuthorizationFailed` | HTTP 403 from Gatekeeper | JWT or app lacks permission |
| `GeolocationNotSupported` | Browser has no Geolocation API | Use a supported browser; cannot recover on that client |
| `NoRecipeFound` | No backend recipe for your app config | Contact Bespot with `applicationId` + `applicationVersion` |
| `NoCheckFound` | No checks available for your app | Contact Bespot with `applicationId` + `applicationVersion` |
| `NetworkError` | Browser could not reach Gatekeeper (`fetch` failed) | Check network, `baseUrl`, HTTPS; if DevTools shows CORS, contact Bespot ([§13](#cors-errors-in-the-browser)) |
| `ServerError` | Gatekeeper returned HTTP 5xx | Retry later; contact Bespot if persistent |
| `InvalidResponseError` | Response body was missing required fields | Contact Bespot if persistent |
| `StorageUnavailable` | Browser storage could not be used (cookies, localStorage, etc.) | Retry in a normal browser session; ask the user to allow site data if prompted |
| `UnknownError` | Unclassified failure | Log `error.message`; contact support |

---

## 10. Geolocation

The SDK uses the browser **Geolocation API** to obtain the user's location during checks. The browser will prompt the user for permission when location is requested.

**Your responsibility:** Explain to your users why location access is needed — before or when your app runs Gatekeeper checks. Clear messaging helps users make an informed choice.

**If the user denies permission:** Checks that depend on user location will not work. Plan your UX, permission flow, and fallback behavior accordingly.

**Requirements:** Production sites must be served over **HTTPS** (browsers block geolocation on non-secure origins).

---

## 11. Access token rotation

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
const result = await sdk.check()
if (result instanceof Error && result.name === 'AuthenticationFailed') {
  const fresh = await fetch('/api/gatekeeper-token').then((r) => r.text())
  sdk.setAccessToken(fresh.trim())
  await sdk.check() // optional immediate retry
}
```

**Note:** If a `check()` is already in flight when you call `setAccessToken`, that request keeps the old token. The new token applies to the **next** call.

---

## 12. Common integration mistakes

| Mistake | What happens | What to do instead |
|---------|--------------|-------------------|
| Calling `check()` before `await initialize()` | `NotInitialized` | Always `initialize` first |
| Using `try/catch` around `check()` only | Missed failures | Use `if (result instanceof Error)` |
| Passing arguments to `subscribe()` | Not supported | Call `subscribe()` with no arguments; interval comes from [server registration](#periodic-checks) |
| Using SDK tarball version as `applicationVersion` | `NoRecipeFound` or auth errors | Use the app version registered with Bespot |
| Trailing slash on `baseUrl` | May cause bad URLs | Use `https://gatekeeper.bespotcompany.com` not `https://gatekeeper.bespotcompany.com/` |
| Putting `client_secret` in frontend | Security risk | Token exchange on your server only |
| Calling `initialize()` on every JWT refresh | Unnecessary re-registration | Use `setAccessToken()` after the first `initialize()` |
| Loading UMD script before `__SAFE_SDK_CONFIG__` | `InvalidSDKConfiguration` | Config script must run **first** |
| Expecting `.env` in the tarball to configure production | Nothing happens | Set runtime config in your host page or `runtime-config.js` |

---

## 13. Troubleshooting

### `initialize` throws immediately

1. JWT is a non-empty string with exactly two dots (three segments).
2. All four config fields are set and non-empty.
3. JWT is not expired (get a fresh one from your backend).
4. Browser can reach `baseUrl` (open DevTools → Network tab).
5. CORS allows your site's origin on Gatekeeper responses — if not, see [CORS errors](#cors-errors-in-the-browser).

### CORS errors in the browser

CORS (Cross-Origin Resource Sharing) is enforced by the browser. The SDK calls your Gatekeeper `baseUrl` directly from the user's browser, so that host must respond with headers that allow **your site's origin** (for example `https://mywebapp.mycompany.com`).

**Typical symptoms**

- DevTools → Console: messages such as `blocked by CORS policy`, `No 'Access-Control-Allow-Origin' header`, or failed **preflight** (`OPTIONS`) requests.
- DevTools → Network: Gatekeeper requests marked as failed before a response body is returned; the SDK may surface `NetworkError` on `initialize` or `check`.

**Gatekeeper `baseUrl` (contact Bespot)**

You cannot allowlist your origin in JavaScript or by changing SDK config. Bespot must enable CORS for your production (and staging) origins on the Gatekeeper environment tied to your `baseUrl`.

If the failing request URL matches your `baseUrl` (e.g. `https://gatekeeper.bespotcompany.com/...`), contact **Bespot** and include:

- Your site's **origin** as shown in the browser (scheme + host + port, e.g. `https://shop.example.com`)
- Your `applicationId` and `applicationVersion`
- The exact CORS message from DevTools (screenshot or copy/paste)
- Whether the failure happens on `initialize`, `check`, or both

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
2. Confirm you did not call `unsubscribe()` earlier on the same page.

### Periodic checks seem to stop or slow down

1. The SDK **pauses** the timer while the tab is **hidden** and resumes when visible — this is intentional.
2. Confirm you did not call `unsubscribe()`.

### `StorageUnavailable` on `initialize`

Browser storage (cookies, localStorage, etc.) could not be used — for example in private mode or with strict tracking protection.

1. Ask the user to allow site data or retry in a normal browser window.
2. Retry `initialize()` in a standard (non-private) session.

---

## 14. Security

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

## 15. SDK version upgrades

To upgrade the SDK:

**npm:** `npm install @bespot/gatekeeper-web-sdk@latest`

**CDN / self-hosted:**
1. Download the newer bundles from [GitHub Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases).
2. Replace the hosted `safe-sdk.esm.min.js` and/or `safe-sdk.umd.min.js` files.

After upgrading either way:
1. Re-test `initialize` → `check` → `subscribe` in staging.
2. Read [CHANGELOG](../CHANGELOG.md) for that release before deploying to production.

Upgrading the SDK does **not** change your `applicationVersion` config field unless **you** choose to.

---

## 16. Support

When contacting Bespot support, include:

- SDK package version (e.g. `gatekeeper-web-sdk-1.0.0.tgz` → `1.0.0`)
- `applicationId` and `applicationVersion` from your config
- `error.name` and `error.message`
- Whether the problem occurs on `initialize` or `check`
- Browser name, version, and operating system
- Approximate time (UTC) of the failure

Authentication reference: [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

---
