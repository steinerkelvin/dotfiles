_: {
  flake.homeModules.shell = { pkgs, ... }: {
    home.packages = [
      # Fuzzy finder
      pkgs.fzf
      # Modern ls replacement
      pkgs.eza
      # Fast grep replacement
      pkgs.ripgrep
      # Smart cd
      pkgs.zoxide
      # Better cat
      pkgs.bat
      # Fast find
      pkgs.fd
      # JSON processor
      pkgs.jq
      # YAML processor
      pkgs.yq
      # Terminal multiplexer
      pkgs.tmux
      # Directory tree viewer
      pkgs.tree
      # Community man pages
      pkgs.tlrc
      # Pager (used by git, man, etc; missing in minimal containers like k-sandbox)
      pkgs.less
    ];
  };
}
