# Reusable home-manager module: wl-kbptr — keyboard-driven mouse pointer for
# Wayland. Installs the package and a plain config; the compositor keybinds that
# invoke it live in homeModules.graphical (Super+G tile/split, Super+Shift+G CV
# hints).
#
# In split mode g/n/b = left/right/middle click -- these are home_row_keys' last
# 3 chars (the first 8 are bisect cells; they must be present and must NOT contain
# g/n/b or they'd shadow the click). g/n/b also avoid the hjkl movement keys.
# mode_floating source=detect needs the opencv build of wl-kbptr + wlr-screencopy
# (both compositors support it). Partial config merges over package defaults.
_: {
  flake.homeModules.wl-kbptr =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wl-kbptr ];

      xdg.configFile."wl-kbptr/config".text = ''
        [general]
        home_row_keys=asdfjkl;gnb
        modes=tile,split

        [mode_tile]
        label_symbols=asdfghjklqwertyuiopzxcvbnm

        [mode_floating]
        source=detect

        [mode_click]
        button=left
      '';
    };
}
