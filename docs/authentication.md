# Authentication

JWT access tokens and OAuth for the Gatekeeper Web SDK.

---

## Official reference

- [Bespot Docs](https://docs.bespot.com) — Bespot product documentation
- [Bespot Authentication Guide](https://docs.bespot.com/api/auth) — Bespot authentication API

---

## Credential types

### Browser runtime config (Gatekeeper API)

Set on every page before or when constructing `SafeSDK`:

| Config field | Header / use |
|--------------|--------------|
| `apiKey` | `x-api-key` on Gatekeeper requests |
| `applicationId` | URL path segment |
| `applicationVersion` | URL path segment |
| `baseUrl` | Gatekeeper API root (e.g. `https://gatekeeper.bespotcompany.com`). Trailing slashes are stripped automatically. |

See [Runtime configuration](integration-guide.md#5-runtime-configuration).

### Backend-only (JWT issuance)

Your server uses these to request access tokens via the Kerberos OAuth2 proxy on your Gatekeeper API host. **Never expose `client_secret` in browser code.**

| Name | Purpose |
|------|---------|
| `AUTH_SERVER_URL` | Gatekeeper API root — same host as SDK `baseUrl` (e.g. `https://gatekeeper.bespotcompany.com`) |
| `CLIENT_ID` | OAuth client id |
| `CLIENT_SECRET` | OAuth client secret — server only |
| `SCOPE` | OAuth scope (e.g. `main_antifraud_resource_server/public`) |

The API key in SDK config is for **Gatekeeper** requests, not the OAuth token exchange, unless your auth setup explicitly requires otherwise.

---

## Required flow

```text
Browser  →  GET /api/your-gatekeeper-token  →  Your server
Your server  →  POST /oauth2/token (with client_secret)  →  Gatekeeper API (Kerberos proxy)
Your server  →  returns access_token  →  Browser
Browser  →  sdk.initialize(access_token)
```

---

## Server-side token request

Kerberos exposes `POST /oauth2/token` on your Gatekeeper API host (for example `https://gatekeeper.bespotcompany.com/oauth2/token`).

Your backend performs this call (not the browser):

```http
POST {AUTH_SERVER_URL}/oauth2/token
Content-Type: application/x-www-form-urlencoded
Authorization: Basic Base64(client_id:client_secret)

grant_type=client_credentials&scope={SCOPE}
```

### Success response

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_in": 86400,
  "token_type": "Bearer"
}
```

| Field | Meaning |
|-------|---------|
| `access_token` | JWT string — pass to `sdk.initialize()` or `sdk.setAccessToken()` |
| `expires_in` | Lifetime in **seconds** — schedule refresh before expiry |
| `token_type` | `Bearer` — SDK sends `Authorization: Bearer {access_token}` |

### Error response

Failures use the platform `ErrorResponse` shape (`error_code` + `description`), not RFC OAuth2 `{"error": "..."}`:

```json
{
  "error_code": "invalid-client",
  "description": "Invalid client credentials"
}
```

| HTTP | `error_code` | Default `description` |
|------|--------------|------------------------|
| 400 | `invalid-request` | Invalid OAuth2 request |
| 400 | `unsupported-grant-type` | Only `client_credentials` is supported. |
| 401 | `invalid-client` | Invalid client credentials |
| 401 | `invalid-grant` | Invalid client credentials |
| 401 | `unauthorized-client` | Invalid client credentials |
| 502 | `invalid-response` | Upstream token provider returned an invalid response |
| 500 | `unknown` | Unknown server error |

Parse `error_code` and `description` on non-2xx responses. The `error` field is not returned on this endpoint.

### Browser usage

```js
const jwt = (await fetch('/api/gatekeeper-token').then((r) => r.text())).trim()
await sdk.initialize(jwt)
```

---

## JWT format requirements

- Non-empty string
- Three segments separated by dots: `header.payload.signature`
- Shape validation only in the SDK — expiry and claims are enforced by Gatekeeper

Invalid shape throws `InvalidAccessToken` or `InvalidAccessTokenFormat` during `initialize` or `setAccessToken`.

---

## Access token rotation

| Method | Re-registers device? | When |
|--------|----------------------|------|
| `initialize(jwt)` | Yes (first time per browser profile) | Session bootstrap |
| `setAccessToken(jwt)` | No | JWT refresh after first `initialize` |

```js
// After first successful initialize:
sdk.setAccessToken(freshJwtFromYourBackend)
```

Do **not** call `initialize()` again solely to rotate an expired JWT.

### Proactive refresh

```js
const fresh = await fetch('/api/gatekeeper-token').then((r) => r.text())
sdk.setAccessToken(fresh.trim())
```

### Reactive refresh

When `check()` or a periodic callback returns `AuthenticationFailed`:

```js
const fresh = await fetch('/api/gatekeeper-token').then((r) => r.text())
sdk.setAccessToken(fresh.trim())
await sdk.check() // optional immediate retry
```
