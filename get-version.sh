#!/bin/bash
set -euo pipefail
VERSION=dev
case "${GITHUB_REF_TYPE:-local}" in
local)
    if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
        VERSION="$(git tag --points-at)"
        [[ -z "${VERSION:-}" ]] && VERSION="$(git log -n1 --pretty=format:%h)"
    fi
    ;;
branch)
    VERSION="${GITHUB_SHA:0:7}"
    ;;
tag)
    VERSION="$GITHUB_REF_NAME"
    ;;
*)
    exit 1
    ;;
esac
echo "$VERSION"
