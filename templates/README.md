# Templates

Starter files for Gatekeeper Web SDK integration. Copy into your project and replace placeholder values.

## Prerequisites

1. Get the SDK bundles — either:
   - `npm install @bespot/gatekeeper-web-sdk` and locate `dist/` in `node_modules/@bespot/gatekeeper-web-sdk`, **or**
   - Download `safe-sdk.esm.min.js` / `safe-sdk.umd.min.js` from [GitHub Releases](https://github.com/bespot/gatekeeper-web-sdk-release/releases)
2. Place the bundle file(s) where your web server can serve them (or adjust the paths in the HTML files).
3. Implement a backend endpoint that returns a JWT (e.g. `/api/gatekeeper-token`).

## Files

| File | Purpose |
|------|---------|
| [integration-esm.html](integration-esm.html) | ES module (`import SafeSDK`) |
| [integration-umd.html](integration-umd.html) | Classic script tags + `window.SafeSDK` |
| [runtime-config.example.js](runtime-config.example.js) | `globalThis.__SAFE_SDK_CONFIG__` sample for UMD |

## Values to update

- `baseUrl`, `apiKey`, `applicationId`, `applicationVersion` — replace sample placeholders (see inline `// e.g.` comments in templates)
- `/api/gatekeeper-token` — your backend JWT endpoint
- `/sdk/safe-sdk.*.min.js` — path to your hosted bundle files
