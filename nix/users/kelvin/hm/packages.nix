{ pkgs, heavy ? false, ... }:

let lib = pkgs.lib;

heavyPkgs = [
  # Secrets
  pkgs.pass
  # Image utilities
  pkgs.imagemagick
  # pkgs.zbar # NOTE: depends on ghostscript??
  # Terminal file explorer
  pkgs.yazi
  # Git tools
  pkgs.lazygit
  pkgs.diff-so-fancy
];

heavyLinuxPkgs = [
  # NixOS
  pkgs.nixos-install-tools
];

in {
  home.packages =
    (if heavy then heavyPkgs else []) ++
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
      pkgs.mosh

      ## File utilities
      pkgs.file
      pkgs.tree
      pkgs.eza
      pkgs.bat
      pkgs.dua
      pkgs.fd
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
      pkgs.watch

      ## Network utilities
      pkgs.inetutils
      pkgs.nmap
      pkgs.dig
      pkgs.stc-cli # Syncthing CLI (`stc` command)

      # Secrets
      pkgs.openssl
      pkgs.gnupg
      pkgs.age
      # inputs.agenix.packages.${pkgs.system}.agenix
      # bitwarden-cli
      # pkgs.git-crypt
      pkgs.libsecret

      # Editors
      pkgs.vim

      # Utilities
      pkgs.tldr
      pkgs.todoist

      # Image utilities
      pkgs.qrencode

      # Dev
      pkgs.gnumake
      pkgs.docker-compose

      pkgs.difftastic

      ## Git
      pkgs.tig
      pkgs.gh
      #pkgs.gita

      ## Package managers
      pkgs.yarn
      pkgs.nodejs
      pkgs.bun

      ## Language managers
      pkgs.rustup
      #haskellPackages.ghcup

      pkgs.python312
      pkgs.python312Packages.pip
      pkgs.python312Packages.pipx
      pkgs.python312Packages.ipython
      pkgs.uv

    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux system utilities
      pkgs.lshw
      pkgs.usbutils
      pkgs.iotop
      pkgs.ncdu
    ] ++ lib.optionals (heavy && pkgs.stdenv.isLinux) heavyLinuxPkgs;
}
