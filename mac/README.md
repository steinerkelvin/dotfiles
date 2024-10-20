## macOS

Some Homebrew packages at [my-brew-formulae.sh]:
```sh
sh ./mac/my-brew-formulae.sh
```

- Enable `Use F1, F2, etc. keys as standard function keys`

- [Superkey]
  - Disable `Include shift in hyper key`
  - Hyper key will be `Ctrl + Option + Cmd` (used in skhd)
  - Enable `Launch on login`
- [skhd] — key bindings
  - `skhd --start-service`
  - Check config for default terminal
- [Yabai] — tiling windows
  - `yabai --start-service`
  - [Disabling System Integrity Protection](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
  - [Configure scripting addition](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition)
- [AltTab]
- [Raycast]
- [BetterDisplay]

[Superkey]: https://superkey.app/
[Yabai]: https://github.com/koekeishiya/yabai
[skhd]: https://github.com/koekeishiya/skhd
[AltTab]: https://alt-tab-macos.netlify.app/
[Raycast]: https://raycast.com/
[BetterDisplay]: https://github.com/waydabber/BetterDisplay

[my-brew-formulae.sh]: mac/my-brew-formulae.sh
