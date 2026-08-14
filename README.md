# Ben Bazzite

Ben Bazzite is a personal, NVIDIA-focused [bootc](https://bootc-dev.github.io/bootc/) desktop image built on Bazzite. It replaces the stock GNOME session with a polished Hyprland desktop, a custom Quickshell login screen, and an Aurora-themed DankMaterialShell interface while retaining Bazzite's gaming stack and atomic update model.

> [!NOTE]
> This is a personal image tuned for its owner's hardware and workflow. Review the base image, NVIDIA assumptions, and desktop configuration before installing it elsewhere.

## What it includes

- Hyprland as the only advertised desktop session
- A custom greetd and Quickshell login screen instead of GDM
- DankMaterialShell (DMS) for the top bar, launcher, notifications, OSD, quick controls, and power menu
- A supervised DMS user service that restores the shell after a crash
- Aurora glass colors, wallpaper, GTK/Qt styling, and a matching Ghostty configuration
- Native-resolution XWayland behavior for games on fractionally scaled displays
- Hyprlock, Hypridle, Hyprpaper, screenshots, media controls, and a built-in shortcut guide
- Bazzite's NVIDIA, Steam, gaming, container, and atomic-update foundation

## Upstream dependencies

Ben Bazzite is not based on DankLinux. Its primary upstream is Bazzite; the DankLinux packages appear because DMS declares its matching runtime repository.

| Layer | Source | Role |
| --- | --- | --- |
| Base image | `ghcr.io/ublue-os/bazzite-gnome-nvidia-open:stable` | Fedora Atomic base, NVIDIA open driver stack, Steam, gaming tools, and bootc integration |
| Desktop compositor | `lionheartp/Hyprland` COPR | Hyprland and its companion utilities on the current Fedora base |
| Desktop shell | `avengemedia/dms` COPR | DankMaterialShell and its required DankLinux runtime packages |
| Login manager | Fedora `greetd` package | Starts the image-owned Quickshell greeter and Hyprland session |
| Terminal | Terra `ghostty` package | Default terminal |
| Build tooling | Universal Blue bootc workflow | OCI builds, GHCR publishing, signing, and optional disk images |

The build enables third-party repositories only for the relevant package transaction and disables them again in the final image.

## Install

From an existing bootc-compatible system, switch to the published image and reboot:

```bash
sudo bootc switch ghcr.io/bensanex/ben-bazzite:latest
sudo systemctl reboot
```

Inspect the current and staged deployments at any time with:

```bash
bootc status
```

Future image updates use the normal bootc workflow:

```bash
sudo bootc update
sudo systemctl reboot
```

If a deployment causes trouble, select the previous deployment from the boot menu or run `sudo bootc rollback` before rebooting.

## Everyday controls

The complete shortcut reference is available with `Super+F1`. Common bindings include:

| Shortcut | Action |
| --- | --- |
| `Super+Return` | Open Ghostty |
| `Super+D` | Open the DMS launcher |
| `Super+E` | Open Files |
| `Super+A` | Open quick controls |
| `Super+N` | Open notifications |
| `Super+,` | Open DMS settings |
| `Super+L` | Lock the session |
| `Super+Shift+E` | Open the power menu |
| `Super+F1` | Show all shortcuts |

## Repository layout

- [`Containerfile`](./Containerfile) selects the Bazzite base and runs the image build.
- [`build_files/build.sh`](./build_files/build.sh) installs packages, removes the unused GNOME/GDM surface, applies DMS patches, copies image-owned files, and verifies the result.
- [`build_files/dms-tooltips.patch`](./build_files/dms-tooltips.patch) contains the maintained DMS bar tooltip and widget-host changes. The build intentionally fails if upstream DMS drifts far enough that this patch no longer applies.
- [`system_files/`](./system_files) is copied over the final filesystem and contains the greeter, Hyprland session, DMS theme and plugin, services, scripts, wallpapers, and application defaults.
- [`.github/workflows/build.yml`](./.github/workflows/build.yml) builds and publishes the OCI image to GitHub Container Registry.
- [`Justfile`](./Justfile) provides local image, rechunking, VM, ISO, and cleanup tasks.

User-editable Hyprland configuration is seeded from `/usr/share/hypr/hyprland.lua` into `~/.config/hypr/hyprland.lua`. Existing user configuration is preserved across image updates.

## Build locally

You need [just](https://just.systems/), [Podman](https://podman.io/), and `jq`. Bazzite and other Universal Blue systems normally include them.

Check the Justfile and build the image:

```bash
just check
sudo just build ben-bazzite latest
```

The rootful build can be switched into directly for testing:

```bash
sudo podman image list --filter=label=containers.bootc=1
sudo bootc switch --transport containers-storage localhost/ben-bazzite:latest
sudo systemctl reboot
```

To produce the same smaller-delta layout used by CI, rechunk the built image first:

```bash
sudo just ostree-rechunk ben-bazzite latest
```

Other useful recipes:

```bash
just --list
just clean
just build-qcow2 ben-bazzite latest
just run-vm-qcow2 ben-bazzite latest
```

The full container build performs more than package installation: it verifies the Hyprland configurations, greetd handoff, DMS patch, shell service, theme files, helper scripts, portal configuration, and final bootc image.

## Publishing and signing

GitHub Actions builds pull requests and publishes `main` to `ghcr.io/bensanex/ben-bazzite`. Published images are signed with Cosign using the repository's `SIGNING_SECRET`.

To rotate or recreate the signing key:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair
gh secret set SIGNING_SECRET < cosign.key
```

Commit `cosign.pub`, but never commit `cosign.key`.

## Disk images

The repository retains the Universal Blue bootc-image-builder workflow and Just recipes for QCOW2, raw, and installer images. The current disk configuration is inherited scaffolding and must be updated to point at `ghcr.io/bensanex/ben-bazzite:latest` before treating generated installers as release media.

Optional S3 uploads use these GitHub Actions secrets:

- `S3_PROVIDER`
- `S3_BUCKET_NAME`
- `S3_ACCESS_KEY_ID`
- `S3_SECRET_ACCESS_KEY`
- `S3_REGION`
- `S3_ENDPOINT`

Without S3 upload enabled, manually dispatched disk builds are stored as GitHub Actions artifacts.

## Upstream resources

- [Bazzite documentation](https://docs.bazzite.gg/)
- [Universal Blue](https://universal-blue.org/)
- [bootc documentation](https://bootc-dev.github.io/bootc/)
- [Hyprland documentation](https://wiki.hypr.land/)
- [DankMaterialShell documentation](https://danklinux.com/docs/dankmaterialshell/)
- [Universal Blue community forum](https://universal-blue.discourse.group/)
