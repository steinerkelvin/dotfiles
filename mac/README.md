# macOS

## Nix

Run `./deploy-home-manager.sh` to set up home-manager. The script will offer to install Nix via the Determinate Installer if not already present.

## Brew packages

Some Homebrew packages are at [my-brew-formulae.sh]:

```sh
sh mac/my-brew-formulae.sh
```

[my-brew-formulae.sh]: my-brew-formulae.sh

## Mac settings

Some macOS settings are at [macos-settings.sh].

- Enable `Use F1, F2, etc. keys as standard function keys`
- Keyboard layout to disable `Option+<letter>` symbols
  - Allows biding these combinations to other stuff
  - https://apple.stackexchange.com/q/388552

[macos-settings.sh]: macos-settings.sh

## Apps

- [Superkey]
  - Disable `Include shift in hyper key`
  - Enable `Launch on login`
  - Hyper key will be `Ctrl + Option + Cmd` (used in Aerospace etc)
- [AeroSpace]
- [AltTab]
- [Raycast]
- [BetterDisplay]

[AeroSpace]: https://github.com/nikitabobko/AeroSpace
[Superkey]: https://superkey.app/
[AltTab]: https://alt-tab-macos.netlify.app/
[Raycast]: https://raycast.com/
[BetterDisplay]: https://github.com/waydabber/BetterDisplay

---

Old tiling window manager setup was done with [yabai] and [skhd].

[yabai]: https://github.com/koekeishiya/yabai
[skhd]: https://github.com/koekeishiya/skhd
