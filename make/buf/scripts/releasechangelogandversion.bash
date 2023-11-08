#!/usr/bin/env bash

set -euo pipefail

DIR="$(CDPATH= cd "$(dirname "${0}")/../../.." && pwd)"
cd "${DIR}"

if [[ -z "${VERSION}" ]]; then
  echo "error: env var VERSION is empty" >&2
  exit 1
elif [[ "${VERSION}" == v* ]]; then
  echo "error: env var VERSION ${VERSION} must not start with 'v'" >&2
  exit 1
fi

echo "Version is ${VERSION}"

make updateversion
make releasechangelog

branch="release/v${VERSION}"
git checkout -b ${branch}
git add .
git commit -m "Update version to v${VERSION}"
git push origin ${branch} --force
gh pr create --title "Release v${VERSION}" --body "Release prepared for ${VERSION}
Reminder: Verify the changelog"