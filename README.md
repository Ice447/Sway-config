# Sway Desktop Configuration

Personal desktop configuration for Sway, Waybar, and Wofi.

## What Is Here

- `sway/`: compositor config, lock screen scripts, and static theme colors.
- `waybar/`: bar config, static CSS, and one helper script for power/system actions.
- `wofi/`: launcher config and static CSS.

Theme files are kept in the repo because they are the active files used by the desktop session:

- `sway/theme.conf`
- `sway/scripts/lock-colors.sh`
- `waybar/style.css`
- `wofi/style.css`

## Dependencies

Core session tools:

- `sway`
- `waybar`
- `wofi`
- `swayidle`
- `swaylock`

Helper scripts expect:

- `bash`
- `python3`
- `curl`
- `imagemagick`
- `powerprofilesctl`
- `nmcli`
- `bluetoothctl`
- `pactl`
- `brightnessctl`
- `grim`
- `slurp`
- `wl-copy`
- `wl-paste`
- `cliphist`
- `swaynag`
- `notify-send` (optional notifications)

Configured apps referenced by autostart or keybindings:

- `foot`
- `firefox`
- `elecwhat`
- `vesktop`
- `gnome-keyring-daemon`
- `blueman-manager`
- `pavucontrol`
- `nm-connection-editor`

## Common Commands

Reload the running Sway session:

```sh
swaymsg reload
```

## Local Assumptions

The default wallpaper path is:

```text
~/.wallpaper/background.png
```

The repo lives directly under `~/.config`, so `.gitignore` ignores everything by default and then allows only this dotfiles codebase.
