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
    dhall

    # Essential
    curl
    wget
    rsync
    openssh
    git
    pkgs.moreutils
    ## Build
    pkgs.gnumake
    pkgs.clang
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
    ranger
    bat
    unzip
    croc
    ## Misc
    httpie
    jq
    jc
    pkgs.yq
    pkgs.envsubst

    pkgs.yggdrasil

    # System utilities
    pkgs.killall
    pkgs.htop
    pkgs.pstree
    pkgs.bottom
    pkgs.lshw
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
    bitwarden-cli
    inputs.agenix.packages.${pkgs.system}.agenix
    git-crypt
    libsecret
    # pkgs.veracrypt

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
    pkgs.zbar
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
    # Linux system utilities
    pkgs.iotop
    pkgs.usbutils
    pkgs.ncdu
    # Nix
    pkgs.nixos-install-tools
  ];
}
