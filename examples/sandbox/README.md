# Credentials sandbox

Manual harness to verify your Gatekeeper Web SDK credentials against the **exact**
bundles in this repository’s `dist/` folder (UMD and ESM).

This is **not** a production integration starter. For copy-paste app scaffolding,
use [`templates/`](../templates/).

## Sandbox warning

**Get JWT** calls the OAuth token endpoint from the browser and requires your
OAuth **client secret** in the page. Anyone who can open the page can read that
secret.

- Use only for local / private credential checks.
- **Never** ship `client_secret` in a production frontend.
- Production apps must mint JWTs on your server — see
  [Authentication](../docs/authentication.md).

## Open the pages

From the **release repository root** (not `file://`):

```bash
npm run sandbox:umd
# or
npm run sandbox:esm
```

That serves the repo and opens the matching page in your browser.

Equivalent one-liners:

```bash
npx --yes http-server . -o /examples/sandbox/umd.html
npx --yes http-server . -o /examples/sandbox/esm.html
```

Manual alternative: `npx serve .` then open:

- [UMD sandbox](./umd.html) → `/examples/sandbox/umd.html`
- [ESM sandbox](./esm.html) → `/examples/sandbox/esm.html`

Each page loads:

- UMD: `../../dist/safe-sdk.umd.min.js` via `window.SafeSDK`
- ESM: `../../dist/safe-sdk.esm.min.js` via `import`

The version badge reads `../../package.json`. If the SDK fails to load, you are
usually not serving from the repo root.

## Credentials checklist

| Field | Used for |
| --- | --- |
| Backend URL (`baseUrl`) | SDK runtime — Gatekeeper API root |
| API key | SDK runtime — `x-api-key` |
| Application ID | SDK runtime — path segment |
| Application version | SDK runtime — path segment |
| Cognito / auth host | Get JWT only (sandbox) |
| Client ID / Client secret | Get JWT only (sandbox) |
| OAuth scope | Get JWT only |
| JWT | `sdk.initialize(jwt)` — paste or Get JWT |

Suggested flow: fill config → **Get JWT** (or paste a token) → **Initialize** →
**Check**.

## Common issues

### Cognito CORS on Get JWT

Many Cognito/token hosts block browser `Origin`s. If Get JWT fails with a
network/CORS error, mint a token with curl (or your backend) and paste it into
**JWT**:

```bash
curl -sS --request POST \
  --url 'https://YOUR_AUTH_HOST/oauth2/token' \
  --user 'CLIENT_ID:CLIENT_SECRET' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode 'scope=YOUR_SCOPE'
```

### Initialize → “could not reach the server” (`NetworkError`)

Usually a **browser CORS** failure on Gatekeeper `POST …/register`, not a wrong
API key. Confirm:

1. Your page **Origin** (scheme + host + port) is allowlisted for the Gatekeeper
   environment behind `baseUrl`.
2. Preflight allows **`POST`** (and the headers the SDK sends: `Authorization`,
   `Content-Type`, `x-api-key`).
3. `applicationId` is the Gatekeeper application id — it is **not** the same
   thing as the page Origin (though they can look similar for WEB apps).

See also [Troubleshooting](../docs/integration-guide.md#13-troubleshooting) in
the integration guide.
