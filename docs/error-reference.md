# Error reference

Gatekeeper Web SDK failure types and handling rules.

---

## Handling rules

There are **two** error behaviors. Mixing them up is the most common integration bug.

### Rule 1: `initialize` and `setAccessToken` throw

Always wrap in `try/catch`:

```js
try {
  await sdk.initialize(jwt)
} catch (error) {
  console.error('Initialize failed:', error.name, error.message)
}
```

### Rule 2: `check` returns an error — it does not throw

Always use `instanceof Error`:

```js
const result = await sdk.check()
if (result instanceof Error) {
  console.error('Check failed:', result.name, result.message)
} else {
  console.log('Check succeeded:', result.action, result.ticket)
}
```

---

## Error catalog

When logging errors, use **`error.name`** and **`error.message`**.

| `error.name` | Meaning | Typical fix |
|--------------|---------|-------------|
| `InvalidSDKConfiguration` | Missing or empty `baseUrl`, `apiKey`, `applicationId`, or `applicationVersion` | Set all four config fields before `new SafeSDK()` |
| `InvalidAccessToken` | JWT is empty or only whitespace | Pass a non-empty token to `initialize` |
| `InvalidAccessTokenFormat` | JWT is not `xxx.yyy.zzz` (three non-empty parts) | Fix token format from your auth server |
| `NotInitialized` | `check()` before successful `initialize`, or only `setAccessToken` was called | Call `await initialize(jwt)` first |
| `InvalidApiKey` | Gatekeeper rejected the API key | Verify `apiKey` with Bespot |
| `AuthenticationFailed` | HTTP 401 from Gatekeeper | JWT expired or invalid — [access token rotation](integration-guide.md#11-access-token-rotation) |
| `AuthorizationFailed` | HTTP 403 from Gatekeeper | JWT or app lacks permission |
| `GeolocationNotSupported` | Browser has no Geolocation API | Use a supported browser |
| `NoRecipeFound` | No backend recipe for your app config | Contact Bespot with `applicationId` + `applicationVersion` |
| `NoCheckFound` | No checks available for your app | Contact Bespot with `applicationId` + `applicationVersion` |
| `NetworkError` | Browser could not reach Gatekeeper (`fetch` failed) | Check network, `baseUrl`, CORS, HTTPS |
| `ServerError` | Gatekeeper returned HTTP 5xx | Retry later; contact Bespot if persistent |
| `InvalidResponseError` | Response body was missing required fields | Contact Bespot if persistent |
| `StorageUnavailable` | Storage unavailability may limit some SDK features | Retry in a normal browser session; ask the user to allow site data if prompted |
| `UnknownError` | Unclassified failure | Log `error.message`; contact support |

---

## Geolocation-related outcomes

Geolocation is not always a hard error. After a successful `check()`, use `getLastGeolocationFailure()`:

| Value | Meaning |
|-------|---------|
| `null` | Location was read successfully |
| `geoapi_permission_denied` | User denied permission; check still ran |
| `geoapi_position_unavailable` | Position unavailable; check still ran |
| `geoapi_timeout` | Timeout; check still ran |
| `geoapi_unknown_error` | Non-standard geolocation error; check still ran |
| `geoapi_unavailable` | API missing; `check()` returns `GeolocationNotSupported` instead |

See [Geolocation](integration-guide.md#10-geolocation).

