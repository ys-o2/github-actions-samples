#!/usr/bin/env bash

VERSION=$1
SEMVER_REGEX="^v([0-9]+)\.([0-9]+)\.([0-9]+)$"
if [[ ! "${VERSION}" =~ ${SEMVER_REGEX} ]]; then
    echo "Invalid version: ${VERSION}"
    exit 1
fi
echo "Version is valid: ${VERSION}"
