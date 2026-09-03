# macOS platform layer: home directory shape, Homebrew shellenv, GNU userland,
# and the GUI PATH snapshot. Darwin-only -- importing this on Linux will fail on
# `launchd.agents`, which only exists in home-manager's darwin module set.
#
# Lives here rather than in a profile because the downstream Darwin host config
# used to reach it by file path (`dotfiles + "/profiles/..."`), which breaks the
# moment the file moves. Exported as a homeModule instead, so the coupling is
# the flake output rather than the tree layout.
#
# Identity-free by construction: every path derives from
# `config.home.homeDirectory`, which the consumer sets.
_: {
  flake.homeModules.darwin-platform =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;

      # PATH snapshotted into the GUI launchd session on login. Only stable
      # paths are embedded: nix store paths (`/nix/store/<hash>/bin`) change on
      # every activation, and the profile symlinks below cover the same tooling.
      pathEntries = [
        "${home}/.local/bin"
        "${home}/bin"
        "${home}/.nix-profile/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];
    in
    {
      home.homeDirectory = lib.mkDefault "/Users/${config.home.username}";

      programs.zsh.initContent = ''
        test -e "/opt/homebrew/bin/brew" && eval "$(/opt/homebrew/bin/brew shellenv)"
      '';

      # macOS ships BSD variants; scripts here assume GNU behaviour.
      home.packages = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.gnused
        pkgs.gnugrep
        pkgs.gawk
      ];

      # Without this, apps spawned from the Dock, Spotlight, or Finder (kitty,
      # VS Code, etc.) inherit launchd's minimal default PATH and cannot resolve
      # bare-name tools like `claude`, `bun`, or `just`.
      #
      # home-manager bootstraps the agent into `gui/$UID` on the next switch.
      # Already-running GUI apps keep their old PATH until they are relaunched
      # (or you log out and back in).
      launchd.agents.set-path = {
        enable = true;
        config = {
          ProgramArguments = [
            "/bin/launchctl"
            "setenv"
            "PATH"
            (builtins.concatStringsSep ":" pathEntries)
          ];
          RunAtLoad = true;
          KeepAlive = false;
        };
      };
    };
}
