#!/usr/bin/env bash

set -euo pipefail

DIR="$(CDPATH= cd "$(dirname "${0}")/../../.." && pwd)"
cd "${DIR}"

# We already have set -u, but want to fail early if a required variable is not set.
: ${GH_TOKEN}
# : ${WEBHOOK_URL}

# uncomment for bufbuild/buf
# : ${RELEASE_MINISIGN_PRIVATE_KEY}
# : ${RELEASE_MINISIGN_PRIVATE_KEY_PASSWORD}
# make bufrelease
# unset RELEASE_MINISIGN_PRIVATE_KEY
# unset RELEASE_MINISIGN_PRIVATE_KEY_PASSWORD

# This starts a loop after seeing the first line starting with ## [. For each line in the loop, it is skipped (n)
# if it's empty (^$). The loop ends (q) if it sees another line starting with '## ['. Otherwise it gets printed.
release_notes=$(sed -n '/## \[/{
:loop n;
/^$/n;
/## \[/q;
p;
b loop
}' CHANGELOG.md)

# The second ${VERSION} is the tag see https://cli.github.com/manual/gh_release_create
url=$(gh release create --draft --notes "$(release_notes)" --title "v${VERSION}" "v${VERSION}" .build/release/buf/assets/*)

# add slack
echo "A release has been drafted at ${url}" 