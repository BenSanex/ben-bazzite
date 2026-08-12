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
    hyprland-guiutils \
    hyprpaper \
    hyprlock \
    hypridle \
    hyprpolkitagent \
    hyprshutdown \
    waybar \
    fuzzel \
    mako \
    brightnessctl \
    pavucontrol \
    blueman \
    network-manager-applet \
    wlogout \
    xdg-desktop-portal-hyprland
dnf5 -y copr disable lionheartp/Hyprland

# Fail the image build if the compositor, portal, or GDM session entry is lost.
test -x /usr/bin/start-hyprland
test -x /usr/bin/ghostty
test -x /usr/bin/hyprpaper
test -x /usr/bin/hyprlock
test -x /usr/bin/hypridle
test -x /usr/bin/hyprshutdown
test -x /usr/bin/waybar
test -x /usr/bin/fuzzel
test -x /usr/bin/wlogout
test -x /usr/libexec/xdg-desktop-portal-hyprland
test -f /usr/share/wayland-sessions/hyprland.desktop
grep -q '^Exec=/usr/bin/start-hyprland$' /usr/share/wayland-sessions/hyprland.desktop

# Apply image-owned files after RPM installation so the maintained Ben Bazzite
# fallback config replaces Hyprland's packaged example.
cp -avf "/ctx/system_files"/. /
chmod 0755 \
    /usr/bin/ben-bazzite-hyprland-apply \
    /usr/libexec/ben-bazzite/keybinds \
    /usr/libexec/ben-bazzite/screenshot
grep -q 'local terminal = "ghostty"' /usr/share/hypr/hyprland.lua
grep -q 'hyprland.start' /usr/share/hypr/hyprland.lua
test -f /usr/share/backgrounds/ben-bazzite/aurora-glass.png
test -f /etc/xdg/waybar/config.jsonc
install -d -m 0700 -o nobody -g nobody /tmp/hypr-verify
test -x /usr/bin/setpriv
setpriv --reuid=nobody --regid=nobody --clear-groups env \
    HOME=/tmp/hypr-verify \
    XDG_RUNTIME_DIR=/tmp/hypr-verify \
    Hyprland --verify-config -c /usr/share/hypr/hyprland.lua
fuzzel --config=/etc/xdg/fuzzel/fuzzel.ini --check-config
jq empty /etc/xdg/waybar/config.jsonc
bash -n \
    /usr/bin/ben-bazzite-hyprland-apply \
    /usr/libexec/ben-bazzite/keybinds \
    /usr/libexec/ben-bazzite/screenshot

#### Example for enabling a System Unit File

systemctl enable podman.socket
