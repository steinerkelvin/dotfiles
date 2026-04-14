{ ... }: {
  flake.homeModules.shell = { pkgs, ... }: {
    home.packages = [
      # Modern ls replacement
      pkgs.eza
      # Fuzzy finder
      pkgs.fzf
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
      # Terminal multiplexer
      pkgs.tmux
    ];
  };
}
