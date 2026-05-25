# Reusable NixOS module: base profile — nix settings, zsh, basic packages, GC.
#
# Host-specific bits are intentionally NOT set here: `nix.settings.trusted-users`
# (a username) and the unstable-package overlay (nixosModules.unstable-packages)
# are supplied by the consumer.
_: {
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      nix = {
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          builders-use-substitutes = true;
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
      };

      # Zsh — needed so NixOS adds it to /etc/shells for login shell
      programs.zsh.enable = true;

      # Basic packages
      environment.systemPackages = [
        pkgs.vim
        pkgs.git
        pkgs.htop
        pkgs.tmux
      ];
    };
}
