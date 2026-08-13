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
    libnotify \
    playerctl \
    slurp \
    wl-clipboard \
    brightnessctl \
    pavucontrol \
    blueman \
    network-manager-applet \
    xdg-desktop-portal-hyprland
dnf5 -y copr disable lionheartp/Hyprland

# DankMaterialShell supplies the Quickshell bar, launcher, notifications, OSD,
# and quick controls. Its stable COPR declares the matching DankLinux runtime
# repository, so keep the single source scoped to this transaction.
dnf5 -y copr enable avengemedia/dms
dnf5 install -y dms
dnf5 -y copr disable avengemedia/dms

# Add concise, live-data tooltips to every shared DMS bar pill and make the
# hover highlight distinct from the deliberately transparent idle surface.
# Applying this as a checked patch lets upstream drift fail the build instead
# of silently installing a partially customized shell.
git apply \
    --unsafe-paths \
    --directory=/usr/share/quickshell/dms \
    /ctx/dms-tooltips.patch

# Fail the image build if either desktop session, the compositor, or the
# portal is lost. GDM will offer both GNOME and Hyprland at sign-in.
test -x /usr/bin/start-hyprland
test -x /usr/bin/gnome-session
test -x /usr/bin/gnome-control-center
test -x /usr/bin/dms
test -x /usr/bin/qs
grep -Fq '"CPU " + value.toFixed(0) + "%";' \
    /usr/share/quickshell/dms/Modules/Plugins/BasePill.qml
grep -Fq 'item.widgetId = widgetId;' \
    /usr/share/quickshell/dms/Modules/DankBar/WidgetHost.qml
test -x /usr/bin/ghostty
test -x /usr/bin/hyprpaper
test -x /usr/bin/hyprlock
test -x /usr/bin/hypridle
test -x /usr/bin/hyprshutdown
test -x /usr/bin/grim
test -x /usr/bin/gtk-launch
test -x /usr/bin/notify-send
test -x /usr/bin/playerctl
test -x /usr/bin/slurp
test -x /usr/bin/zenity
test -x /usr/bin/wl-copy
test -x /usr/libexec/xdg-desktop-portal-hyprland
test -f /usr/share/wayland-sessions/hyprland.desktop
grep -q '^Exec=/usr/bin/start-hyprland$' /usr/share/wayland-sessions/hyprland.desktop
test -f /usr/share/wayland-sessions/gnome.desktop
grep -q '^Name=GNOME$' /usr/share/wayland-sessions/gnome.desktop
grep -q '^Exec=/usr/bin/gnome-session$' /usr/share/wayland-sessions/gnome.desktop
settings_panels="$(env XDG_CURRENT_DESKTOP=GNOME gnome-control-center --list)"
for settings_panel in wifi bluetooth sound; do
    grep -Eq "^[[:space:]]+${settings_panel}$" <<<"${settings_panels}"
done

# Apply image-owned files after RPM installation so the maintained Ben Bazzite
# fallback config replaces Hyprland's packaged example.
cp -avf "/ctx/system_files"/. /

# Keep the greeter override in the immutable image rather than /etc, which is
# three-way merged across bootc deployments. Put it immediately after GDM's
# user database so it overrides both persistent and vendor Bazzite defaults.
dconf compile \
    /usr/share/ben-bazzite/gdm \
    /usr/share/ben-bazzite/gdm.d
sed -i \
    '/^user-db:user$/a file-db:/usr/share/ben-bazzite/gdm' \
    /usr/share/dconf/profile/gdm

chmod 0755 \
    /usr/bin/ben-bazzite-hyprland-apply \
    /usr/libexec/ben-bazzite/dark-theme \
    /usr/libexec/ben-bazzite/dms-start \
    /usr/libexec/ben-bazzite/keybinds \
    /usr/libexec/ben-bazzite/session-start \
    /usr/libexec/ben-bazzite/scratchpad-status \
    /usr/libexec/ben-bazzite/screenshot
grep -q 'local terminal = "ghostty"' /usr/share/hypr/hyprland.lua
grep -q 'local launcher = "dms ipc call spotlight toggle"' \
    /usr/share/hypr/hyprland.lua
grep -q 'hyprland.start' /usr/share/hypr/hyprland.lua
test -f /usr/share/backgrounds/ben-bazzite/aurora-glass.png
test -f /usr/share/backgrounds/ben-bazzite/aurora-glass-gdm.png
test -f /usr/share/ben-bazzite/dms-theme.json
test -f /etc/xdg/quickshell/dms-plugins/benOsHelp/plugin.json
test -f /etc/xdg/quickshell/dms-plugins/benOsHelp/BenOsHelp.qml
test -f /etc/ben-bazzite/ben-os-gdm-logo.png
test -f /etc/xdg/gtk-3.0/settings.ini
test -f /etc/xdg/gtk-4.0/settings.ini
test -f /etc/xdg/ghostty/config
test -f /etc/xdg/xdg-desktop-portal/hyprland-portals.conf
test -f /etc/dconf/profile/user
test -f /usr/lib/systemd/user/ben-bazzite-hyprland-session.target
test -f /usr/share/themes/adw-gtk3-dark/index.theme
test ! -e /etc/dconf/profile/gdm
test "$(sed -n '2p' /usr/share/dconf/profile/gdm)" = \
    'file-db:/usr/share/ben-bazzite/gdm'
grep -Fxq 'file-db:/usr/share/gdm/greeter-dconf-defaults' \
    /usr/share/dconf/profile/gdm
grep -Fxq "logo='/etc/ben-bazzite/ben-os-gdm-logo.png'" \
    /usr/share/ben-bazzite/gdm.d/00-ben-bazzite-dark
grep -Fxq '/org/gnome/desktop/background/picture-uri' \
    /usr/share/ben-bazzite/gdm.d/locks/00-ben-bazzite-greeter
grep -q '^org.freedesktop.impl.portal.Settings=gtk$' \
    /etc/xdg/xdg-desktop-portal/hyprland-portals.conf
fc-match Roboto | grep -qi 'Roboto'
dconf update
test "$(DCONF_PROFILE=/usr/share/dconf/profile/gdm \
    dconf read /org/gnome/desktop/background/picture-uri)" = \
    "'file:///usr/share/backgrounds/ben-bazzite/aurora-glass-gdm.png'"
test "$(DCONF_PROFILE=/usr/share/dconf/profile/gdm \
    dconf read /org/gnome/login-screen/logo)" = \
    "'/etc/ben-bazzite/ben-os-gdm-logo.png'"
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
    XDG_CONFIG_HOME=/tmp/hypr-verify/config \
    /usr/bin/ben-bazzite-hyprland-apply
cmp -s /usr/share/hypr/hyprland.lua \
    /tmp/hypr-verify/config/hypr/hyprland.lua
setpriv --reuid=nobody --regid=nobody --clear-groups env \
    HOME=/tmp/hypr-verify \
    XDG_RUNTIME_DIR=/tmp/hypr-verify \
    Hyprland --verify-config -c /usr/share/hypr/hyprland.lua
XDG_CONFIG_HOME=/etc/xdg ghostty +show-config --changes-only >/dev/null
jq -e '.name == "Ben OS Aurora" and .primary == "#6ee7fa"
    and .secondary == "#9b7bff" and .error == "#ff7a90"' \
    /usr/share/ben-bazzite/dms-theme.json >/dev/null
jq -e '.id == "benOsHelp" and .type == "widget"
    and (.capabilities | index("dankbar-widget"))' \
    /etc/xdg/quickshell/dms-plugins/benOsHelp/plugin.json >/dev/null
jq -e '.text == "" and .class == "empty"' \
    < <(/usr/libexec/ben-bazzite/scratchpad-status) >/dev/null
bash -n \
    /usr/bin/ben-bazzite-hyprland-apply \
    /usr/libexec/ben-bazzite/dark-theme \
    /usr/libexec/ben-bazzite/dms-start \
    /usr/libexec/ben-bazzite/keybinds \
    /usr/libexec/ben-bazzite/session-start \
    /usr/libexec/ben-bazzite/scratchpad-status \
    /usr/libexec/ben-bazzite/screenshot

#### Example for enabling a System Unit File

systemctl enable podman.socket
