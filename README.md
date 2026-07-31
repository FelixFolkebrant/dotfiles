# Dotfiles

Arch Linux and Hyprland setup managed with GNU Stow.

## Install

Clone this repository as `~/dotfiles`, then run:

```bash
cd ~/dotfiles
./setup.sh
```

The setup performs these steps in order:

1. Installs official packages, including the tools referenced by the configs.
2. Optionally creates or displays a GitHub SSH public key.
3. Installs `yay`, required AUR packages, and optionally desktop applications.
4. checks for Stow conflicts before creating any links.
5. Installs the Zsh plugins over public HTTPS URLs.
6. Applies the dark GTK/GNOME preference.
7. Enables NetworkManager, Bluetooth, keyd, and power-profiles-daemon.

Stow deliberately does not use `--adopt`. If it reports a conflict, move the
reported file to a backup and rerun setup. `--adopt` moves target files into
the repository and can overwrite the tracked dotfiles.

## Post-reinstall recovery

An earlier run with `stow --adopt` can leave machine-owned data inside this
repository. On the current reinstall, this happened to the VS Code extensions
directory: `~/.vscode/extensions` points to about 4 GiB under the repository.
Review the paths first:

```bash
readlink ~/.vscode/extensions
du -sh ~/dotfiles/vscode/.vscode/extensions
readlink ~/.vscode/settings.json
```

If the output confirms that layout, restore the extensions to their normal
location with:

```bash
unlink ~/.vscode/extensions
mv ~/dotfiles/vscode/.vscode/extensions ~/.vscode/extensions
git -C ~/dotfiles restore vscode/.vscode/extensions/ayu-mirage-mod
```

The old Stow run also linked the global VS Code settings file to editor
metadata from one of the dotfile packages. Remove that incorrect link only
after checking it:

```bash
readlink ~/.vscode/settings.json
unlink ~/.vscode/settings.json
```

The updated Stow rules ignore project-local `.vscode` metadata and all VS Code
extensions except the tracked `ayu-mirage-mod` theme.

## Hyprland and keybind debugging

Hyprland 0.55 and newer load `~/.config/hypr/hyprland.lua`. The old
`hyprland.conf` format is not the active configuration on current Hyprland.

Validate the config without launching a second compositor:

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
hyprctl configerrors
```

Confirm that the brightness and lock-in bindings were registered:

```bash
hyprctl binds | rg 'XF86MonBrightness|F11'
```

### Power profiles and refresh rate

`Super+F5` cycles Power Save → Balanced → Performance. The profile helper
applies the power-profiles-daemon platform/CPU policy and switches Hyprland's
blur, shadow, and animation effects off only in Power Save. Brightness remains
fully manual. On this Ryzen laptop,
power-profiles-daemon controls the AMD P-state governor and EPP; it intentionally
keeps the kernel's global boost switch enabled, while Power Save uses the
`power` EPP to strongly avoid boost. The machine has a Radeon 680M iGPU and no
discrete GPU, so there is no dGPU to power down.

`Fn+R` is bound as `XF86RefreshRateToggle` and changes silently. The
internal LEN151WQXGA panel currently advertises only 60 Hz and 165 Hz. The
helper prefers the order 60 → 90 → 165 but safely skips 90 Hz because it is
not a valid panel mode; it never forces a custom modeline.

Validate the current state or test the scripts directly:

```bash
~/.config/hypr/powerprofiles-toggle.sh --status
~/.config/hypr/refresh-rate-toggle.sh
hyprctl monitors all
```

If `Fn+R` does not trigger it, run `wev`, press the key, and replace the bind
keysym with the event's `sym` value. The kernel must expose
`XF86RefreshRateToggle` for the supplied bind to receive it.

### Brightness

The old config forced the device name `intel_backlight`, but this reinstall
exposes `amdgpu_bl1`. The new commands let `brightnessctl` select the backlight
device. Test the command independently of Hyprland:

```bash
brightnessctl --list
brightnessctl -e4 -n2 set 5%+
```

If that succeeds but the key does nothing, run `wev`, focus its window, and
press the brightness key. It should report `XF86MonBrightnessUp` or
`XF86MonBrightnessDown`. A different symbol must be used in the bind.

If the command reports a permission error, log out and back in after installing
`brightnessctl` so its udev permissions are applied, then inspect:

```bash
ls -l /sys/class/backlight
groups
```

### Volume and brightness OSD

The media keys and Waybar volume scrolling show a minimal, vertically centered
right-edge indicator: a context-aware volume or brightness icon beside a thin
vertical progress bar. The icon sits inside the bottom of the wider track, and
the fill updates immediately for each change. Normal brightness keys change
10%; hold Ctrl for 2% changes. It uses Eww from the required AUR package list.

After setup, log out and back in, or reload it immediately with:

```bash
~/bin/restart_ui.sh
```

The reveal and hide transitions are each 120 ms; the indicator remains visible
for just over one second after the last change. To test without changing a
device value, call either helper directly:

```bash
bash ~/.config/eww/scripts/osd.sh volume
bash ~/.config/eww/scripts/osd.sh brightness
```

### Lock-in mode

The old bind called `~/lockin.sh`, but `scripts/` was excluded from Stow. The
helper now installs at `~/.config/hypr/lockin.sh`. Test it directly:

```bash
bash -x ~/.config/hypr/lockin.sh
```

The first run hides Waybar and Hyprpaper and removes all visual and input
insets (inner and outer gaps plus the extended border-grab area), borders,
rounding, and shadows without showing a notification; normal animations stay
enabled. The second run reloads the config and restarts the bar and wallpaper.
Its state file is under `$XDG_RUNTIME_DIR`. Because this is a Lua Hyprland
config, the helper applies its runtime overrides through `hyprctl eval` rather
than the legacy `hyprctl keyword` command.

### Runtime event trail

Use these commands when a bind still fails:

```bash
wev
hyprctl binds
hyprctl configerrors
hyprctl rollinglog -f
```

Start with `wev`: no key event means the problem is below Hyprland (firmware,
Fn-lock, or keyd). An event with no matching entry in `hyprctl binds` points to
the config. A registered bind whose command fails should then be run manually
in a terminal.

## Services, portals, and dark mode

Check the explicitly enabled system services:

```bash
systemctl --no-pager --full status \
  NetworkManager.service bluetooth.service keyd.service \
  power-profiles-daemon.service
journalctl -b -u keyd.service
```

PipeWire, WirePlumber, and XDG desktop portals are user-session or D-Bus
activated and should not be enabled as system services. Inspect them with:

```bash
systemctl --user --no-pager --full status \
  pipewire.service pipewire-pulse.service wireplumber.service \
  xdg-desktop-portal.service xdg-desktop-portal-hyprland.service
```

Verify the dark appearance values:

```bash
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
```

Expected values are `prefer-dark` and `Adwaita-dark`.

## Zsh plugins and GitHub SSH

The plugin problem was not shallow cloning. Three plugin paths were recorded as
Git gitlinks without a `.gitmodules` file. A fresh clone therefore had
placeholder directories that the old installer mistook for completed clones.
The gitlinks are removed, the generated plugin directory is ignored, and the
installer now verifies each plugin's actual entrypoint.

Public plugins use HTTPS and do not require GitHub authentication. The SSH step
is for pushing dotfile changes. It only prints `.pub` files, never private keys,
and links to:

<https://github.com/settings/ssh/new>

Verify the plugins after setup:

```bash
test -s ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
test -s ~/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
test -s ~/.local/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
test -s ~/.local/share/zsh/plugins/calc/calc.plugin.zsh
```
