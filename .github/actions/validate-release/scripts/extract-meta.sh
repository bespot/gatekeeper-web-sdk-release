#!/usr/bin/env bash
set -euo pipefail

if ! [[ "${BRANCH}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "::error::Branch '${BRANCH}' does not match release/vX.Y.Z convention."
  exit 1
fi

tag="${BRANCH#release/}"
version="${tag#v}"
echo "tag=${tag}" >> "${GITHUB_OUTPUT}"
echo "version=${version}" >> "${GITHUB_OUTPUT}"
