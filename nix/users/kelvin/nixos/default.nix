{ lib, config, pkgs, inputs, ... }:

let
  username = "kelvin";
  # unstable = (import inputs.unstable { system = pkgs.system; });

in {
  imports = [
    ./noise-supression.nix
  ];

  config = {

    # TODO: integrate this better on separate module
    modules.services.spotifyd.enable = true;

    # TODO: separate user module for shell
    programs.zsh.enable = true;

    users.users."${username}" = {
      isNormalUser = true;
      description = "Kelvin";
      extraGroups = [ "wheel" "networkmanager" "audio" "podman" ];
      shell = pkgs.zsh;
      packages = with pkgs; [ firefox kate ];
    };

    home-manager.users."${username}" = { pkgs, config, lib, ... }: {

      imports = [
        ../hm/common.nix
        ../hm/graphical.nix
      ];

      home.username = username;
      home.homeDirectory = "/home/${username}";

      home.stateVersion = "22.11";

      programs.gpg.enable = true;

      services.keybase.enable = true;
      services.kbfs.enable = true;

      # Enable user fonts
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        # Nix tools
        direnv
        nix-direnv
        nix-index
        nixos-option
        nixfmt
        nixpkgs-fmt
        dhall
        home-manager

        ## App Image
        appimage-run

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

        # System utilities
        htop
        pstree
        lsof
        iotop
        ## Network utilities
        inetutils
        nmap
        dig

        # Secrets
        gnupg
        git-crypt
        libsecret

        # Shell
        # zsh
        # zsh-autosuggestions
        # zsh-syntax-highlighting
        # starship
        zoxide
        nerdfonts

        # Editors
        vim
        helix

        # Utilities
        pdftk

        # Dev
        ## Git
        tig
        gh
        ## Package managers
        yarn
        nodejs
        ## Language managers
        rustup
        #haskellPackages.ghcup

        python310
        python310Packages.ipython
      ];

      home.file.".Xmodmap".text = ''
        keycode 66 = Hyper_L

        clear lock
        clear mod3
        clear mod4

        add mod3 = Hyper_L
        add mod4 = Super_L Super_R
      '';

      # Spotifyd
      # TODO: move to module
      services.spotifyd = {
        enable = true;
        settings = {
          global = {
            device_name = "nixia";
            zeroconf_port = 57621;
            username = "kelvinsteiner";
            # password = "<pass>";   # TODO: secrets
          };
        };
      };

      # XDG User Dirs
      home.file = {
        ".config/user-dirs.dirs".text = ''
          XDG_DESKTOP_DIR="$HOME/desktop"
          XDG_DOWNLOAD_DIR="$HOME/downloads"
          XDG_TEMPLATES_DIR="$HOME/templates"
          XDG_PUBLICSHARE_DIR="$HOME/public"
          XDG_DOCUMENTS_DIR="$HOME/documents"
          XDG_MUSIC_DIR="$HOME/music"
          XDG_PICTURES_DIR="$HOME/pictures"
          XDG_VIDEOS_DIR="$HOME/videos"
        '';
      };

    # end home-manager.users.${username}
    };

  # end config
  };
}
