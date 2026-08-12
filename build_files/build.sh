#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Terra is already configured (and disabled) by Bazzite. Enable it for this
# transaction only so it remains disabled in the final image.
dnf5 --enable-repo=terra install -y ghostty

# Hyprland is currently unavailable from Fedora 44. Use the Fedora source
# recommended by Hyprland upstream, then leave it disabled in the final image.
dnf5 -y copr enable lionheartp/Hyprland
dnf5 install -y \
    hyprland \
    xdg-desktop-portal-hyprland
dnf5 -y copr disable lionheartp/Hyprland

# Fail the image build if the compositor, portal, or GDM session entry is lost.
test -x /usr/bin/start-hyprland
test -x /usr/bin/ghostty
test -x /usr/libexec/xdg-desktop-portal-hyprland
test -f /usr/share/wayland-sessions/hyprland.desktop
grep -q '^Exec=/usr/bin/start-hyprland$' /usr/share/wayland-sessions/hyprland.desktop

# Apply image-owned files after RPM installation so the maintained Ben Bazzite
# fallback config replaces Hyprland's packaged example.
cp -avf "/ctx/system_files"/. /
grep -q 'hl.dsp.exec_cmd("ghostty")' /usr/share/hypr/hyprland.lua

#### Example for enabling a System Unit File

systemctl enable podman.socket
