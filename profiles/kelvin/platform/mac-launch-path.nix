_:

# User LaunchAgent that snapshots a sane PATH into the GUI launchd session on
# login via `launchctl setenv PATH ...`. Without this, apps spawned from the
# Dock, Spotlight, or Finder (kitty, VS Code, etc.) inherit launchd's minimal
# default PATH and cannot resolve bare-name tools like `claude`, `bun`, or
# `just`.
#
# Only stable paths are embedded here. Nix store paths
# (`/nix/store/<hash>/bin`) are intentionally excluded because they change on
# every activation; the stable profile symlinks below cover the same tooling.
#
# Activation: home-manager bootstraps the agent into `gui/$UID` on the next
# `home-manager switch`. Already-running GUI apps keep their old PATH until
# they are relaunched (or you log out and back in).

let
  pathEntries = [
    "/Users/kelvin/.local/bin"
    "/Users/kelvin/bin"
    "/Users/kelvin/.nix-profile/bin"
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
  pathValue = builtins.concatStringsSep ":" pathEntries;
in
{
  launchd.agents.set-path = {
    enable = true;
    config = {
      ProgramArguments = [ "/bin/launchctl" "setenv" "PATH" pathValue ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
}
