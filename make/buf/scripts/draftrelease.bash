#!/usr/bin/env bash

set -euo pipefail

DIR="$(CDPATH= cd "$(dirname "${0}")/../../.." && pwd)"
cd "${DIR}"

# We already have set -u, but want to fail early if a required variable is not set.
# However, if you are already logged in for GitHub CLI locally, you can remove this line when running it locally.
: ${GH_TOKEN}
: ${VERSION}
# : ${WEBHOOK_URL}

if [[ "${VERSION}" == v* ]]; then
  echo "error: VERSION ${VERSION} must not start with 'v'" >&2
  exit 1
fi

# uncomment for bufbuild/buf
# : ${RELEASE_MINISIGN_PRIVATE_KEY}
# : ${RELEASE_MINISIGN_PRIVATE_KEY_PASSWORD}
# make bufrelease
# unset RELEASE_MINISIGN_PRIVATE_KEY
# unset RELEASE_MINISIGN_PRIVATE_KEY_PASSWORD

if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
  SED_BIN=sed
elif [[ "${OSTYPE}" == "darwin"* ]]; then
  SED_BIN=gsed
else
  echo "unsupported OSTYPE: ${OSTYPE}"
  exit 1
fi

# This starts a loop after seeing the first line starting with ## [. For each line in the loop, it is skipped (n)
# if it's empty (^$). The loop ends (q) if it sees another line starting with '## ['. Otherwise it gets printed.
release_notes=$(${SED_BIN} -n '/## \[/{
:loop n;
/^$/n;
/## \[/q;
p;
b loop
}' CHANGELOG.md)

# The second ${VERSION} is the tag see https://cli.github.com/manual/gh_release_create
# todo: use this
# url=$(gh release create --draft --notes "${release_notes}" --title "v${VERSION}" "v${VERSION}" .build/release/buf/assets/*)
url=$(gh release create --draft --notes "${release_notes}" --title "v${VERSION}" "v${VERSION}" ./random.txt)

# todo: add slack
echo "A release has been drafted at ${url}" 
# jq --null-input "{text:\"BufCLI Release ${VERSION} is complete: ${url}\"}" | curl -sSL -X POST -H 'Content-Type: application/json' -d@- "${WEBHOOK_URL}"