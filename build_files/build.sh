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
    google-roboto-fonts \
    grim \
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
    libnotify \
    playerctl \
    slurp \
    wl-clipboard \
    brightnessctl \
    pavucontrol \
    blueman \
    network-manager-applet \
    wlogout \
    xdg-desktop-portal-hyprland
dnf5 -y copr disable lionheartp/Hyprland

# SwayOSD's upstream Fedora package provides native volume and brightness
# feedback. Keep its COPR enabled only for the installation transaction.
dnf5 -y copr enable erikreider/swayosd
dnf5 install -y swayosd
dnf5 -y copr disable erikreider/swayosd

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
test -x /usr/bin/grim
test -x /usr/bin/gtk-launch
test -x /usr/bin/notify-send
test -x /usr/bin/playerctl
test -x /usr/bin/slurp
test -x /usr/bin/swayosd-client
test -x /usr/bin/swayosd-server
test -x /usr/bin/wl-copy
test -x /usr/libexec/xdg-desktop-portal-hyprland
test -f /usr/share/wayland-sessions/hyprland.desktop
grep -q '^Exec=/usr/bin/start-hyprland$' /usr/share/wayland-sessions/hyprland.desktop

# Apply image-owned files after RPM installation so the maintained Ben Bazzite
# fallback config replaces Hyprland's packaged example.
cp -avf "/ctx/system_files"/. /

# GNOME 50's greeter defaults must remain in the GDM profile. Derive our
# profile from the vendor version on every build, then place the Ben OS
# database before the vendor defaults because dconf gives earlier databases
# higher precedence.
cp /usr/share/dconf/profile/gdm /etc/dconf/profile/gdm
sed -i \
    '\|^file-db:/usr/share/gdm/greeter-dconf-defaults$|i system-db:ben-gdm' \
    /etc/dconf/profile/gdm
chmod 0755 \
    /usr/bin/ben-bazzite-hyprland-apply \
    /usr/libexec/ben-bazzite/dark-theme \
    /usr/libexec/ben-bazzite/keybinds \
    /usr/libexec/ben-bazzite/session-start \
    /usr/libexec/ben-bazzite/scratchpad-status \
    /usr/libexec/ben-bazzite/screenshot
grep -q 'local terminal = "ghostty"' /usr/share/hypr/hyprland.lua
grep -q 'hyprland.start' /usr/share/hypr/hyprland.lua
test -f /usr/share/backgrounds/ben-bazzite/aurora-glass.png
test -f /etc/ben-bazzite/ben-os-gdm-logo.png
test -f /etc/xdg/waybar/config.jsonc
test -f /etc/xdg/gtk-3.0/settings.ini
test -f /etc/xdg/gtk-4.0/settings.ini
test -f /etc/xdg/ghostty/config
test -f /etc/xdg/xdg-desktop-portal/hyprland-portals.conf
test -f /etc/dconf/profile/user
test -f /usr/lib/systemd/user/ben-bazzite-hyprland-session.target
test -f /usr/share/themes/adw-gtk3-dark/index.theme
grep -Fxq 'file-db:/usr/share/gdm/greeter-dconf-defaults' \
    /etc/dconf/profile/gdm
test "$(grep -nFx 'system-db:ben-gdm' /etc/dconf/profile/gdm | cut -d: -f1)" \
    -lt \
    "$(grep -nFx 'file-db:/usr/share/gdm/greeter-dconf-defaults' \
        /etc/dconf/profile/gdm | cut -d: -f1)"
grep -Fxq "logo='/etc/ben-bazzite/ben-os-gdm-logo.png'" \
    /etc/dconf/db/ben-gdm.d/00-ben-bazzite-dark
grep -q '^org.freedesktop.impl.portal.Settings=gtk$' \
    /etc/xdg/xdg-desktop-portal/hyprland-portals.conf
fc-match Roboto | grep -qi 'Roboto'
dconf update
install -d -m 0700 -o nobody -g nobody /tmp/hypr-verify
install -d -m 0700 -o nobody -g nobody /tmp/theme-verify
test -x /usr/bin/setpriv
setpriv --reuid=nobody --regid=nobody --clear-groups env \
    HOME=/tmp/theme-verify \
    XDG_CONFIG_HOME=/tmp/theme-verify/config \
    GSETTINGS_BACKEND=memory \
    /usr/libexec/ben-bazzite/dark-theme
cmp -s /etc/xdg/ghostty/config /tmp/theme-verify/config/ghostty/config
setpriv --reuid=nobody --regid=nobody --clear-groups env \
    HOME=/tmp/hypr-verify \
    XDG_RUNTIME_DIR=/tmp/hypr-verify \
    Hyprland --verify-config -c /usr/share/hypr/hyprland.lua
LC_ALL=C.UTF-8 fuzzel --config=/etc/xdg/fuzzel/fuzzel.ini --check-config
XDG_CONFIG_HOME=/etc/xdg ghostty +show-config --changes-only >/dev/null
jq empty /etc/xdg/waybar/config.jsonc
jq -e '.text == "" and .class == "empty"' \
    < <(/usr/libexec/ben-bazzite/scratchpad-status) >/dev/null
bash -n \
    /usr/bin/ben-bazzite-hyprland-apply \
    /usr/libexec/ben-bazzite/dark-theme \
    /usr/libexec/ben-bazzite/keybinds \
    /usr/libexec/ben-bazzite/session-start \
    /usr/libexec/ben-bazzite/scratchpad-status \
    /usr/libexec/ben-bazzite/screenshot

#### Example for enabling a System Unit File

systemctl enable podman.socket
