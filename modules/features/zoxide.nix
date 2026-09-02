# Native zoxide integration, shared by zsh and bash. Replaces the
# oh-my-zsh "zoxide" plugin (zsh-only) so bash gets `z`/`zi` too.
_: {
  flake.homeModules.zoxide = _: {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
