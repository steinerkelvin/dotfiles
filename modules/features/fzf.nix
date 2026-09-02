# Native fzf integration (key bindings + completion), shared by zsh and
# bash. Replaces the oh-my-zsh "fzf" plugin (zsh-only).
_: {
  flake.homeModules.fzf = _: {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
