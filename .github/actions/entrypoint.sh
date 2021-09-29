#!/bin/bash

set -o errexit -o pipefail -o nounset

# Ensure wheel group exists
groupadd -f -r wheel

echo '::group::Creating updater user'
useradd --create-home --shell /bin/bash --groups wheel updater
passwd --delete updater
echo '::endgroup::'

echo '::group::Adding updater user to sudoers'
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo '::endgroup::'

exec runuser updater --command 'bash -l -c /update.sh'