#!/bin/bash
# shellcheck disable=SC2024

set -o errexit -o pipefail -o nounset

pkgbuild=$INPUT_PKGBUILD
pkgver=$INPUT_PKGVER
assets=$INPUT_ASSETS

assert_non_empty() {
  name=$1
  value=$2
  if [[ -z "$value" ]]; then
    echo "::error::Invalid Value: $name is empty." >&2
    exit 1
  fi
}

assert_non_empty inputs.pkgbuild "$pkgbuild"
assert_non_empty inputs.pkgver "$pkgver"

if [[ $pkgver == v* ]];
then
  pkgver=${pkgver:1}
fi

# Ignore "." and ".." to prevent errors when glob pattern for assets matches hidden files
GLOBIGNORE=".:.."

echo '::group::Copying files locally'
sudo mkdir -p /tmp/pkg

sudo cp $pkgbuild /tmp/pkg/PKGBUILD

# Ignore quote rule because we need to expand glob patterns to copy $assets
if [[ -n "$assets" ]]; then
  sudo cp -rt /tmp/pkg/ $assets
fi

sudo chown -R updater:updater /tmp/pkg
echo '::endgroup::'

echo '::group::Updating AUR package version'
sed -i "/^pkgver=/c\pkgver=$pkgver" /tmp/pkg/PKGBUILD
echo '::endgroup::'

echo '::group::Updating package checksum'
updpkgsums /tmp/pkg/PKGBUILD
echo '::endgroup::'

echo '::group::Persisting package update'
sudo cp /tmp/pkg/PKGBUILD $pkgbuild
echo '::endgroup::'