{ inputs, pkgs, ... }:

let lib = pkgs.lib;
in {
  home.packages =
    [
      # Nix tools
      pkgs.direnv
      pkgs.nix-direnv
      pkgs.nix-index
      pkgs.nix-tree
      pkgs.nixos-option
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
      # pkgs.clang
      pkgs.pkg-config
      pkgs.openssl

      # Terminal / Shell tools
      pkgs.zoxide
      pkgs.fzf
      pkgs.stow
      pkgs.silver-searcher
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
      #pkgs.nnn
      #pkgs.broot
      pkgs.unzip
      pkgs.croc

      ## Misc
      # httpie # NOTE: depends on ghostscript??
      pkgs.jq
      pkgs.jc
      pkgs.yq
      pkgs.envsubst

      # System utilities
      pkgs.killall
      pkgs.htop
      pkgs.lsof
      pkgs.pciutils
      pkgs.pstree
      pkgs.bottom

      ## Network utilities
      pkgs.inetutils
      pkgs.nmap
      pkgs.dig

      # Secrets
      pkgs.openssl
      pkgs.gnupg
      pkgs.pass
      pkgs.age
      inputs.agenix.packages.${pkgs.system}.agenix
      # bitwarden-cli
      pkgs.git-crypt
      pkgs.libsecret

      # Editors
      pkgs.vim

      # Utilities
      pkgs.tldr
      pkgs.todoist

      # Image utilities
      pkgs.imagemagick
      # pkgs.zbar # NOTE: depends on ghostscript??
      pkgs.qrencode

      # Dev
      pkgs.gnumake
      pkgs.docker-compose

      pkgs.diff-so-fancy
      pkgs.difftastic

      ## Git
      pkgs.tig
      pkgs.gh
      #pkgs.gita

      ## Package managers
      pkgs.yarn
      pkgs.nodejs

      ## Language managers
      pkgs.rustup
      #haskellPackages.ghcup

      pkgs.python312
      pkgs.python312Packages.pip
      pkgs.python312Packages.ipython

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
