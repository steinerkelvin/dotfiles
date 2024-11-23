{ inputs, pkgs, ... }:

let
  lib = pkgs.lib;
in
{
  home.packages = with pkgs; [
    # Nix tools
    direnv
    nix-direnv
    nix-index
    nix-tree
    nixos-option
    nixfmt-classic
    nixpkgs-fmt
    pkgs.nil

    # Essential
    curl
    wget
    rsync
    openssh
    git
    pkgs.moreutils
    ## Build
    pkgs.gnumake
    # pkgs.clang
    pkgs.pkg-config
    pkgs.openssl

    # Terminal / Shell tools
    fzf
    stow
    silver-searcher
    ripgrep
    diff-so-fancy
    shellcheck
    pkgs.tmux
    pkgs.tmate
    ## File utilities
    file
    pkgs.eza
    tree
    pkgs.dua
    nnn
    broot
    # ranger # NOTE: depends on ghostscript??
    bat
    unzip
    croc
    ## Misc
    # httpie # NOTE: depends on ghostscript??
    jq
    jc
    pkgs.yq
    pkgs.envsubst

    # System utilities
    pkgs.killall
    pkgs.htop
    pkgs.pstree
    pkgs.bottom
    pkgs.lsof
    pkgs.pciutils
    ## Network utilities
    pkgs.inetutils
    pkgs.nmap
    pkgs.dig

    # Secrets
    pkgs.openssl
    gnupg
    pass
    age
    inputs.agenix.packages.${pkgs.system}.agenix
    # bitwarden-cli
    git-crypt
    libsecret

    # Shell
    zoxide

    # Editors
    vim
    helix

    # Utilities
    pkgs.tldr
    pkgs.todoist

    # Image utilities
    pkgs.imagemagick
    # pkgs.zbar # NOTE: depends on ghostscript??
    pkgs.qrencode

    # Dev
    gnumake
    docker-compose
    ## Git
    tig
    gh
    gita
    ## Package managers
    yarn
    nodejs
    ## Language managers
    rustup
    #haskellPackages.ghcup

    python310
    python310Packages.pip
    python310Packages.ipython

  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # NixOS
    pkgs.nixos-install-tools
    # Linux system utilities
    pkgs.lshw
    pkgs.usbutils
    pkgs.iotop
    pkgs.ncdu
  ];
}
