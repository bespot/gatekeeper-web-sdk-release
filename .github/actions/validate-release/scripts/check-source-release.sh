#!/usr/bin/env bash
set -euo pipefail

if [ -z "${SOURCE_REPO:-}" ]; then
  echo "::error::Missing source repo: configure SOURCE_REPO secret (owner/name)."
  exit 1
fi

if [ -z "${SOURCE_REPO_PAT:-}" ]; then
  echo "::error::Missing source repo token: configure SOURCE_REPO_PAT with read access to ${SOURCE_REPO}."
  exit 1
fi

if ! GH_TOKEN="${SOURCE_REPO_PAT}" gh release view "${TAG}" --repo "${SOURCE_REPO}" >/dev/null 2>&1; then
  echo "::error::No source release found for ${TAG} in ${SOURCE_REPO}. Publish the source release before merging this PR."
  exit 1
fi

echo "OK: source release ${TAG} exists in ${SOURCE_REPO}."
