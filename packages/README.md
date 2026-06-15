# SDK packages

This directory stores versioned Gatekeeper Web SDK tarballs.

## Naming

```text
gatekeeper-web-sdk-{semver}.tgz
```

Example: `gatekeeper-web-sdk-1.0.0.tgz`

## Verify a tarball

```bash
tar -tzf gatekeeper-web-sdk-1.0.0.tgz
```

Expected output:

```text
sdk/
sdk/safe-sdk.esm.min.js
sdk/safe-sdk.umd.min.js
```

## Checksums (optional)

After adding packages, regenerate checksums:

```bash
cd packages
shasum -a 256 gatekeeper-web-sdk-*.tgz > SHA256SUMS
```

Integrators can verify downloads with:

```bash
shasum -a 256 -c SHA256SUMS
```
