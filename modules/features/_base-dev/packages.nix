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
    # MOVE: git.nix
    pkgs.lazygit
    pkgs.diff-so-fancy
    pkgs.difftastic

    # Language managers and runtimes live in per-tool files:
    # rust.nix, npm.nix, python.nix
  ];

  heavyLinuxPkgs = [
    # NixOS
    # MOVE: nix.nix
    pkgs.nixos-install-tools
  ];

in
{
  home.packages =
    (if config.k.heavy then heavyPkgs else [ ]) ++
    [
      # MOVE: nix.nix
      # Nix tools
      pkgs.nix-direnv
      pkgs.nix-index
      pkgs.nix-tree
      pkgs.nixfmt-classic
      pkgs.nixpkgs-fmt
      pkgs.nil

      # INS: move to direnv.nix
      pkgs.direnv

      # Essential
      pkgs.curl
      pkgs.wget
      pkgs.rsync
      pkgs.openssh
      pkgs.mosh
      pkgs.git
      pkgs.git-lfs
      pkgs.moreutils
      ## Build
      pkgs.just
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
      pkgs.btop
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

    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux system utilities
      pkgs.lshw
      pkgs.usbutils
      pkgs.iotop
      pkgs.ncdu
    ] ++ lib.optionals (config.k.heavy && pkgs.stdenv.isLinux) heavyLinuxPkgs;
}
