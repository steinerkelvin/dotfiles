_: {
  flake.homeModules.editors = { pkgs, ... }: {
    home.packages = [
      pkgs.vim
      pkgs.nano
    ];

    # Default editor across every host that consumes base-dev. nvim is
    # provided by homeModules.nixvim (also pulled in via base-dev); falling
    # back to vim/nano is fine if a host opts out of nixvim. Without this
    # NixOS would set EDITOR=nano system-wide and leave VISUAL unset, which
    # confuses git, less, etc. that prefer VISUAL.
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}

