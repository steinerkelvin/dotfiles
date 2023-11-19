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
    nixos-option
    nixfmt
    nixpkgs-fmt
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
    exa
    tree
    ncdu
    nnn
    broot
    ranger
    bat
    unzip
    ## Misc
    httpie
    jq
    jc
    tmux
    tmate

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
    gnupg
    age
    inputs.agenix.packages.${pkgs.system}.agenix
    git-crypt
    libsecret

    # Shell
    zoxide

    # Editors
    vim
    helix

    # Utilities
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
