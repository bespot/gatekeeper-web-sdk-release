#!/usr/bin/env bash
set -euo pipefail

if [ -z "${NPM_PACKAGE:-}" ]; then
  echo "::error::Missing npm package: configure NPM_PACKAGE secret."
  exit 1
fi

if [ -z "${GITHUB_REPOSITORY:-}" ]; then
  echo "::error::github_repository input is required when check_not_published is enabled."
  exit 1
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::github_token input is required when check_not_published is enabled."
  exit 1
fi

if gh release view "${TAG}" --repo "${GITHUB_REPOSITORY}" >/dev/null 2>&1; then
  echo "::error::GitHub release ${TAG} already exists in ${GITHUB_REPOSITORY}. Use a new version instead of re-releasing."
  exit 1
fi

npm_version="$(npm view "${NPM_PACKAGE}@${VERSION}" version 2>/dev/null || true)"
if [ -n "${npm_version}" ]; then
  echo "::error::${NPM_PACKAGE}@${VERSION} is already published on npm. Use a new version instead of re-releasing."
  exit 1
fi

echo "OK: ${TAG} is not yet published to GitHub Releases or npm."
