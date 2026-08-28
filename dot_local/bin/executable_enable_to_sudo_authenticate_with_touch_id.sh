#!/bin/bash
# Enable Touch ID authentication for sudo on macOS.
#
# Modern approach (macOS 14 Sonoma and later): write /etc/pam.d/sudo_local.
# Apple's /etc/pam.d/sudo includes sudo_local via "auth include sudo_local",
# and unlike /etc/pam.d/sudo itself, sudo_local is NEVER overwritten by OS
# updates — so this only needs to be run once per machine.
#
# Apple ships a template at /etc/pam.d/sudo_local.template whose only active
# content is a commented-out "auth sufficient pam_tid.so" line; this script
# copies it with that line uncommented.
#
# The old approach (inserting pam_tid.so directly into /etc/pam.d/sudo) broke
# after every macOS update because the installer rewrites that file. Do not
# go back to it.
#
# Notes:
# - Requires macOS 14+. On older systems the "auth include sudo_local" line
#   is absent and this file would have no effect.
# - Inside tmux/screen, pam_tid.so cannot reach Touch ID on its own. If you
#   want fingerprint sudo inside tmux: `brew install pam-reattach`, then add
#   "auth optional pam_reattach.so" as the FIRST line of /etc/pam.d/sudo_local.
# - To revert: sudo rm /etc/pam.d/sudo_local
# - Verify with: sudo -k && sudo true   (should prompt for Touch ID)
set -euo pipefail

if grep -Eq '^auth\s+sufficient\s+pam_tid\.so' /etc/pam.d/sudo_local 2>/dev/null; then
    echo "Touch ID for sudo already enabled in /etc/pam.d/sudo_local"
    exit 0
fi

if [ ! -f /etc/pam.d/sudo_local.template ]; then
    echo "ERROR: /etc/pam.d/sudo_local.template not found (requires macOS 14+)" >&2
    exit 1
fi

sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
echo "Enabled Touch ID for sudo. Test with: sudo -k && sudo true"
