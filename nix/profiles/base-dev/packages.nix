{ pkgs, lib, config, ... }:

let

  heavyPkgs = [
    # Secrets
    pkgs.pass
    # Image utilities
    pkgs.imagemagick
    # Terminal file explorer
    pkgs.yazi
    # Git tools
    pkgs.lazygit
    pkgs.diff-so-fancy
    pkgs.difftastic

    # Language managers
    pkgs.rustup

    ## JS
    pkgs.yarn
    pkgs.nodejs
    pkgs.bun

    ## Python
    pkgs.python312
    pkgs.python312Packages.pip
    pkgs.python312Packages.pipx
    pkgs.python312Packages.ipython
    pkgs.uv

    # Python-based tools
    pkgs.jc # JSON converter for command output (depends on Python)
  ];

  heavyLinuxPkgs = [
    # NixOS
    pkgs.nixos-install-tools
  ];

in
{
  home.packages =
    (if config.k.heavy then heavyPkgs else [ ]) ++
    [
      # Nix tools
      pkgs.direnv
      pkgs.nix-direnv
      pkgs.nix-index
      pkgs.nix-tree
      pkgs.nixfmt-classic
      pkgs.nixpkgs-fmt
      pkgs.nil

      # Essential
      pkgs.curl
      pkgs.wget
      pkgs.rsync
      pkgs.openssh
      pkgs.git
      pkgs.git-lfs
      pkgs.moreutils
      ## Build
      pkgs.gnumake
      pkgs.pkg-config
      pkgs.openssl

      # Terminal / Shell tools
      pkgs.zoxide
      pkgs.fzf
      pkgs.stow
      pkgs.ripgrep
      pkgs.shellcheck
      pkgs.tmux
      pkgs.tmate
      pkgs.abduco
      pkgs.mosh

      ## File utilities
      pkgs.file
      pkgs.tree
      pkgs.eza
      pkgs.bat
      pkgs.dua
      pkgs.fd
      pkgs.unzip
      pkgs.croc

      ## Misc
      pkgs.jq
      pkgs.yq
      pkgs.envsubst

      # System utilities
      pkgs.killall
      pkgs.htop
      pkgs.lsof
      pkgs.pstree
      pkgs.bottom
      pkgs.watch

      ## Network utilities
      pkgs.inetutils
      pkgs.nmap
      pkgs.dig

      # Secrets
      pkgs.gnupg
      pkgs.age
      pkgs.libsecret

      # Editors
      pkgs.vim

      # Utilities
      pkgs.tldr

      ## Git
      pkgs.tig
      pkgs.gh

      # Structural code tools
      pkgs.ast-grep
      # pkgs.comby # broken in current nixpkgs
      pkgs.tree-sitter
      pkgs.tokei
      pkgs.scc

    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux system utilities
      pkgs.lshw
      pkgs.usbutils
      pkgs.iotop
      pkgs.ncdu
    ] ++ lib.optionals (config.k.heavy && pkgs.stdenv.isLinux) heavyLinuxPkgs;
}
