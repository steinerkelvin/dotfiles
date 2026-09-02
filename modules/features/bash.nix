# Bash as a second interactive shell, on equal footing with zsh (see
# modules/features/zsh.nix): same shared init content, same prompt
# (starship.nix), same tool integrations (atuin.nix, zoxide.nix, fzf.nix).
# Does not change the login shell -- see users/kelvin/account.nix.
_: {
  flake.homeModules.bash = _: {
    programs.bash = {
      enable = true;
      initExtra = builtins.readFile ./shell-common.sh;
    };
  };
}
