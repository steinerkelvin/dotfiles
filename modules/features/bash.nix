# Bash as a second interactive shell, on equal footing with zsh (see
# modules/features/zsh.nix): same shared init content, same prompt
# (starship.nix), same tool integrations (atuin.nix, zoxide.nix, fzf.nix).
# Does not change the login shell -- see users/kelvin/account.nix.
_: {
  flake.homeModules.bash = { config, lib, ... }: {
    home.file.".bash_aliases".text = lib.concatStringsSep "\n"
      (
        lib.mapAttrsToList
          (name: value: "alias -- ${lib.escapeShellArg name}=${lib.escapeShellArg value}")
          config.programs.bash.shellAliases
      ) + "\n";

    programs.bash = {
      enable = true;
      initExtra = builtins.readFile ./shell-common.sh;
    };
  };
}
