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
git push --set-upstream origin --force ${branch} 
# This requires GH_TOKEN.
url=$(gh pr create --title "Release v${VERSION}" --body "Release prepared for ${VERSION}
Reminder: Verify the changelog")

jq --null-input "{ text: "BufCLI Release for v${VERSION} has been drafted: ${url}" }" \
curl -sSL -X POST -H "Content-Type: application/json" -d @- "${WEBHOOK_URL}"