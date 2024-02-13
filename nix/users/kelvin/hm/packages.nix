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
    nixfmt
    nixpkgs-fmt
    pkgs.nil
    dhall

    # Essential
    curl
    wget
    rsync
    openssh
    git

    # Terminal / Shell tools
    fzf
    stow
    silver-searcher
    ripgrep
    diff-so-fancy
    shellcheck
    ## File utilities
    file
    pkgs.eza
    tree
    ncdu
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
    tmux
    tmate
    pkgs.envsubst

    pkgs.yggdrasil

    # System utilities
    killall
    htop
    pstree
    lsof
    pciutils
    ## Network utilities
    inetutils
    nmap
    dig

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
    # pdftk # big closure, requires openjdk

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
  ];
}
