#!/usr/bin/env bash
set -euo pipefail

pkg_version="$(jq -r '.version' package.json)"
if [ "${pkg_version}" != "${VERSION}" ]; then
  echo "::error::package.json version (${pkg_version}) does not match release tag (${VERSION})."
  exit 1
fi

for f in dist/safe-sdk.esm.min.js dist/safe-sdk.umd.min.js; do
  if [ ! -s "${f}" ]; then
    echo "::error::${f} is missing or empty."
    exit 1
  fi
done

if [ ! -f LICENSE ]; then
  echo "::error::LICENSE is missing."
  exit 1
fi
