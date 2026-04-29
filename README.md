# Bespot Gatekeeper Web SDK

This guide explains how to install, configure, build, and use the Gatekeeper Web SDK in web applications.

## Table of Contents

1. [Deliverables](#1-deliverables)
2. [Prerequisites](#2-prerequisites)
3. [JWT Access Token Requirements](#3-jwt-access-token-requirements)
4. [Project Installation](#4-project-installation)
5. [Environment Configuration](#5-environment-configuration)
6. [SDK Build Artifacts](#6-sdk-build-artifacts)
7. [Distribution Format Selection (ESM or UMD)](#7-distribution-format-selection-esm-or-umd)
8. [Integration Sequence](#8-integration-sequence)
9. [ESM Integration Example](#9-esm-integration-example)
10. [UMD Integration Example](#10-umd-integration-example)
11. [Error Handling](#11-error-handling)
12. [Error Reference](#12-error-reference)
13. [Troubleshooting](#13-troubleshooting)
14. [Security Best Practices](#14-security-best-practices)

## 1) Deliverables

After building, the repository produces two SDK bundles in `dist/`:

- `gatekeeper.esm.min.js` (for modern module-based apps)
- `gatekeeper.umd.min.js` (for classic `<script>` usage)

These files are what your website loads to run Gatekeeper checks.

## 2) Prerequisites

Make sure you have:

1. Node.js (18 or later)
   - Run: `node -v`
   - Expected: `v18.x.x` or higher

2. Node Package Manager (npm)
   - Run: `npm -v`
   - Expected: Any valid npm version output

3. Repository access
   - Run: `git remote -v` to confirm the configured remote URL
   - Run: `git fetch` to confirm remote read access
   - If access is not configured, Git returns an authentication/permission error

4. `API_KEY` and `APPLICATION_ID`
   - Ensure `.env` contains both variables:
     - `API_KEY=...`
     - `APPLICATION_ID=...`

5. JWT Access Token
   - Confirm the token is present and non-empty

## 3) JWT Access Token Requirements

Before SDK initialization, you must obtain a valid JWT access token.

### Token Acquisition

1. Collect the required credentials:
   - `client_id`
   - `client_secret`
   - `AUTH_SERVER_URL`
   - `X-API-KEY`

2. Request an access token:
   - Endpoint: `POST {AUTH_SERVER_URL}/oauth2/token`
   - Headers:
     - `Content-Type: application/x-www-form-urlencoded`
     - `Authorization: Basic Base64(client_id:client_secret)`
   - Body:
     - `grant_type=client_credentials`

3. Read and store the response values:
   - `access_token` (JWT)
   - `expires_in` (token lifetime in seconds)
   - `token_type` (Bearer)

Example SDK initialization:

```ts
await sdk.initialize("eyJhbGciOi...your-token...abc123")
```

If the token is invalid or expired, initialization fails.

> For full authentication details, see the
> [Bespot Authentication Guide](https://docs.bespot.com/api/auth).

## 4) Project Installation

Run the following commands in order:

1. Clone the repository.

```bash
git clone https://github.com/bespot/gatekeeper-web-sdk-release.git
```

2. Enter the project directory.

```bash
cd gatekeeper-web-sdk-release
```

3. Install dependencies.

```bash
npm install
```

## 5) Environment Configuration

Create your local `.env` file:

```bash
cp .env.sample .env
```

Open `.env` and set your real values:

```bash
API_KEY=your-api-key-goes-here
APPLICATION_ID=your-application-id-goes-here
```

## 6) SDK Build Artifacts
Build once:

```bash
npm run build
```

Expected output files:
- `dist/gatekeeper.esm.min.js`
- `dist/gatekeeper.umd.min.js`

## 7) Distribution Format Selection (ESM or UMD)

- Use `ESM` if your app already uses `import` modules.
  - Example: React/Vue/Angular/Vite/Webpack applications.

- Use `UMD` if your app is plain HTML/JS with `script` tags.
  - Example: server-rendered templates or static HTML pages.

## 8) Integration Sequence
Always use the SDK in this sequence:

- Create SDK instance
- Call `initialize(accessToken)` (required)
- Call `setUserId(userId)` (optional)
- Run `check()` for one-time check(s)
- Run `subscribe(intervalMs, callback)` for periodic checks
- Run `unsubscribe()` when you want periodic checks to stop

## 9) ESM Integration Example

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Gatekeeper SDK - ESM Integration</title>
  </head>
  <body>
    <h1>Gatekeeper SDK Integration</h1>

    <script type="module">
      import SafeSDK from "./dist/gatekeeper.esm.min.js"

      async function startGatekeeper() {
        const sdk = new SafeSDK()

        try {
          // STEP 1: Required - initialize with JWT Access Token
          await sdk.initialize("YOUR_JWT_ACCESS_TOKEN")

          // STEP 2: Optional - set your internal user id
          sdk.setUserId("client-user-123")

          // STEP 3: Run one immediate check
          const result = await sdk.check()

          if (result instanceof Error) {
            console.error("[CHECK ERROR]", result.name, "-", result.message)
          } else {
            console.log("[CHECK SUCCESS]", {
              action: result.action,
              ticket: result.ticket,
            })
          }

          // STEP 4: Start periodic checks every 30 seconds
          sdk.subscribe(30000, (periodicResult) => {
            if (periodicResult instanceof Error) {
              console.error(
                "[PERIODIC CHECK ERROR]",
                periodicResult.name,
                "-",
                periodicResult.message,
              )
              return
            }

            console.log("[PERIODIC CHECK SUCCESS]", {
              action: periodicResult.action,
              ticket: periodicResult.ticket,
            })
          })

          // STEP 5 (later): stop periodic checks when needed
          // sdk.unsubscribe()
        } catch (error) {
          const err = error instanceof Error ? error : new Error(String(error))
          console.error("[INITIALIZATION ERROR]", err.name, "-", err.message)
        }
      }

      startGatekeeper()
    </script>
  </body>
</html>
```

## 10) UMD Integration Example

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Gatekeeper SDK - UMD Integration</title>
  </head>
  <body>
    <h1>Gatekeeper SDK Integration</h1>

    <script src="./dist/gatekeeper.umd.min.js"></script>
    <script>
      ;(async function startGatekeeper() {
        const sdk = new window.SafeSDK()

        try {
          // STEP 1: Required - initialize with JWT Access Token
          await sdk.initialize("YOUR_JWT_ACCESS_TOKEN")

          // STEP 2: Optional - set your internal user id
          sdk.setUserId("client-user-123")

          // STEP 3: Run one immediate check
          const result = await sdk.check()

          if (result instanceof Error) {
            console.error("[CHECK ERROR]", result.name, "-", result.message)
          } else {
            console.log("[CHECK SUCCESS]", {
              action: result.action,
              ticket: result.ticket,
            })
          }

          // STEP 4: Start periodic checks every 30 seconds
          sdk.subscribe(30000, function (periodicResult) {
            if (periodicResult instanceof Error) {
              console.error(
                "[PERIODIC CHECK ERROR]",
                periodicResult.name,
                "-",
                periodicResult.message,
              )
              return
            }

            console.log("[PERIODIC CHECK SUCCESS]", {
              action: periodicResult.action,
              ticket: periodicResult.ticket,
            })
          })

          // STEP 5 (later): stop periodic checks when needed
          // sdk.unsubscribe()
        } catch (error) {
          const err = error instanceof Error ? error : new Error(String(error))
          console.error("[INITIALIZATION ERROR]", err.name, "-", err.message)
        }
      })()
    </script>
  </body>
</html>
```

## 11) Error Handling
There are two places where errors appear:

1. `initialize(...)`

   - Throws an error
   - Must be inside `try/catch`

2. `check()` and `subscribe(...)` callback

   - Returns either a success result or an `Error` object
   - Must be checked with `instanceof Error`

Safe pattern:
```ts
try {
  await sdk.initialize(token)
} catch (error) {
  console.error("Initialization failed:", error)
}

const result = await sdk.check()
if (result instanceof Error) {
  console.error("Check failed:", result.name, result.message)
} else {
  console.log("Check success:", result.action, result.ticket)
}
```

## 12) Error Reference

1. `Failure.AccessTokenRequired`  

The provided JWT Access Token is empty, missing, or invalid for initialization.

2. `Failure.GeolocationNotSupported`  

The browser/device does not support geolocation APIs required by SDK data collection.

3. `Failure.NotInitialized`  

An SDK method was called before successful initialization.

4. `Failure.NetworkConnection`  

The SDK could not contact the backend due to network/connectivity problems.

5. `Failure.NoActiveApiKey`  

Authentication failed, usually because API key is missing, invalid, or not active.

6. `Failure.NoRecipeFoundFailure`  

No valid backend recipe/configuration was found for the current app configuration.

7. `Failure.NoChecksAvailableFailure`  

Backend reports there are no checks available for execution at this time.

8. `Failure.ServerError`  

Backend returned a server-side error (HTTP 5xx).

9. `Failure.InvalidResponseError`  

Backend responded with malformed or incomplete data.

10. `Failure.UnknownError`  

Unexpected/unclassified error not matching the known failure categories.

## 13) Troubleshooting

### Problem: Initialization fails immediately
- Confirm JWT Access Token is valid and not expired.
- Confirm token is passed as a non-empty string.

### Problem: Authentication/authorization errors
- Check `API_KEY` value in `.env`.
- Check `APPLICATION_ID` value in `.env`.

### Problem: Check returns network error
- Confirm internet connectivity.
- Confirm backend endpoints are reachable from client environment.

### Problem: No periodic check results appear
- Verify `subscribe(...)` is called after successful `initialize(...)`.
- Ensure `unsubscribe()` was not called earlier.

### Problem: Unexpected error type
- Log both `error.name` and `error.message`.
- Keep a copy of request context (user id, time, environment) for support.

## 14) Security Best Practices

- Never commit `.env`, access tokens, or secrets.
- Never expose long-lived secrets in frontend code.
- Use short-lived JWT tokens where possible.
- Rotate credentials regularly.
- Use HTTPS only in all environments.
- Store sensitive values in secure secret managers (CI/CD, vaults, environment config).
