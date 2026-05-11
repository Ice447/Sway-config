# Sway Rice

Personal Wayland desktop configuration for Sway, Waybar, Wofi, and Matugen.

## Included

- Sway config split into `sway/config.d/`
- Waybar config, styling, and custom modules
- Wofi launcher styling
- Matugen templates for wallpaper-based colors
- Helper scripts for media controls, power profiles, system toggles, and Home Assistant widgets

## Dependencies

Core:

- `sway`
- `waybar`
- `wofi`
- `matugen`
- `swayidle`
- `swaylock`

Scripts and modules also expect:

- `playerctl`
- `curl`
- `python3`
- `imagemagick`
- `powerprofilesctl`
- `nmcli`
- `bluetoothctl`
- `pactl`
- `grim`
- `slurp`
- `wl-copy`
- `wl-paste`
- `cliphist`

Configured apps and tools referenced by keybindings or autostart:

- `foot`
- `firefox`
- `spotify`
- `elecwhat`
- `vesktop`
- `gnome-keyring-daemon`
- `blueman-manager`
- `pavucontrol`
- `nm-connection-editor`

## Local Files

Secrets are intentionally not tracked. For Home Assistant widgets, copy the example file and fill in local values:

```sh
cp waybar/secrets/homeassistant.env.example waybar/secrets/homeassistant.env
```

Wallpaper-based theming expects:

- `~/.wallpaper/background.png`

You can also pass a wallpaper directly:

```sh
~/.config/matugen/scripts/apply-wallpaper-theme.sh /path/to/wallpaper.png
```

## Layout

```text
matugen/  color generation config and templates
sway/     window manager config and scripts
waybar/   bar config, style, modules, and scripts
wofi/     launcher config, style, and script
```

# Read me !!!!!!!!!!!!!!!!!!
Inspiration: https://www.reddit.com/r/unixporn/comments/nnraix/sway_my_rice_that_just_never_gets_finished/

Nearly all code is AI generated, aswell as this readme. This is kinda just a big test what i can build with just ChatGPT prompting. The code is alot of Spaghetti, though kinda functional.  