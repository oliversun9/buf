#!/usr/bin/env bash

set -euo pipefail

DIR="$(CDPATH= cd "$(dirname "${0}")/../../.." && pwd)"
cd "${DIR}"

if [[ "${VERSION}" == v* ]]; then
  echo "error: VERSION ${VERSION} must not start with 'v'" >&2
  exit 1
fi

# We already have set -u, but need to use this variable to see if it's set.
# GH_TOKEN will be used for creating a PR later on.
echo "${GH_TOKEN}" >> /dev/null

make updateversion
make releasechangelog

branch="release/v${VERSION}"
git switch -C ${branch}
git add .
git commit -m "Update version to ${VERSION}"
git push origin ${branch} --force
# This requires GH_TOKEN.
gh pr create --title "Release v${VERSION}" --body "Release prepared for ${VERSION}
Reminder: Verify the changelog"