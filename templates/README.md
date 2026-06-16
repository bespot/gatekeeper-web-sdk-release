# Templates

Starter files for Gatekeeper Web SDK integration. Copy into your project and replace placeholder values.

## Prerequisites

1. Extract a package from `../packages/`:
   ```bash
   tar -xzf ../packages/gatekeeper-web-sdk-1.0.0.tgz
   ```
2. Place the `sdk/` folder where your web server can serve it (or adjust paths in the HTML files).
3. Implement a backend endpoint that returns a JWT (e.g. `/api/gatekeeper-token`).

## Files

| File | Purpose |
|------|---------|
| [integration-esm.html](integration-esm.html) | ES module (`import SafeSDK`) |
| [integration-umd.html](integration-umd.html) | Classic script tags + `window.SafeSDK` |
| [runtime-config.example.js](runtime-config.example.js) | `globalThis.__SAFE_SDK_CONFIG__` sample for UMD |

## Values to update

- `apiKey`, `applicationId`, `applicationVersion`, `baseUrl` (replace the sample values with yours)
- `/api/gatekeeper-token` — your backend JWT endpoint
- `/sdk/safe-sdk.*.min.js` — path to hosted bundles after extract
