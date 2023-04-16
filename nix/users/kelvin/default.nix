{ lib, config, pkgs, ... }:

let username = "kelvin";
in {
  imports = [ ./graphical.nix ];

  config = {

    users.users."${username}" = {
      isNormalUser = true;
      description = "Kelvin";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
      packages = with pkgs; [ firefox kate ];
    };

    modules.services.spotifyd.enable = true;

    home-manager.users."${username}" = { pkgs, config, lib, ... }: {

      home.username = username;
      home.homeDirectory = "/home/${username}";

      home.stateVersion = "22.11";

      nixpkgs.config.allowUnfree = true;
      programs.home-manager.enable = true;

      home.sessionVariables = {
        EDITOR = "vi -e";
        VISUAL = "hx";
      };

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      programs.gpg.enable = true;

      services.keybase.enable = true;
      services.kbfs.enable = true;

      home.packages = with pkgs; [
        # Nix tools
        direnv
        nix-direnv
        nix-index
        nixos-option
        nixfmt
        dhall
        home-manager
        lorri

        lsof
        inetutils
        nmap
        dig
        pstree

        curl
        wget
        rsync
        openssh
        git

        # Secrets
        gnupg
        git-crypt
        libsecret

        # Shell
        zsh
        zsh-autosuggestions
        zsh-syntax-highlighting
        starship
        zoxide

        # Terminal / shell tools
        fzf
        silver-searcher
        ripgrep
        homesick
        stow
        shellcheck
        diff-so-fancy
        exa
        bat
        htop

        # Editors
        vim
        helix

        rustup

        tig

        python310Packages.ipython

        tabnine

        wakatime

        # GUI

        # GUI Apps
        firefox
        microsoft-edge
        tdesktop
        discord
        calibre
        qbittorrent
        gimp

        # Image editing
        krita
        xkcd-font

        gnome.seahorse

        xorg.xmodmap
        xorg.xev
        xclip
        xdotool
        libnotify
        redshift

        pipewire
        wireplumber
        qpwgraph
        easyeffects

        networkmanagerapplet
        networkmanager_dmenu

        pulseaudio
        pavucontrol
        pulsemixer

        brightnessctl

        libinput

        i3
        i3blocks
        dmenu
        rofi
        dunst
        maim

        sway
        wofi

        wl-clipboard
        slurp
        grim

        imv
        mpv
        viu

        kitty
        vscode
        keybase-gui

        speedcrunch

        spotifyd
      ];

      # Zsh

      programs.zsh.enable = true;

      programs.starship.enable = true;

      home.file.".zshrc".text = ''
        # Load Antigen
        source ${pkgs.antigen}/share/antigen/antigen.zsh

        # Set up Antigen to use oh-my-zsh's library
        #antigen use oh-my-zsh

        # Load the plugins
        antigen bundle git
        antigen bundle zsh-users/zsh-autosuggestions
        antigen bundle zsh-users/zsh-syntax-highlighting
        antigen bundle fzf
        antigen bundle git
        antigen bundle cargo
        antigen bundle pip
        antigen bundle yarn
        antigen bundle command-not-found

        # Load the theme
        #antigen theme robbyrussell
        if command -v "starship" >/dev/null; then
          eval "$(starship init zsh)"
        else
          export AGKOZAK_LEFT_PROMPT_ONLY=1
          export AGKOZAK_BLANK_LINES=1
          antigen theme agkozak/agkozak-zsh-prompt
        fi

        # Apply the settings
        antigen apply

        # Setup Zoxide
        if command -v "zoxide" >/dev/null; then
          eval "$(zoxide init zsh)"
        fi

        # Vim mode
        bindkey -v
      '';

      # Vim

      programs.neovim = {
        enable = true;
        coc = { enable = true; };
        plugins = with pkgs.vimPlugins; [
          vim-nix
          yankring
          zoxide-vim
          which-key-nvim
          vim-easymotion
          vim-multiple-cursors
          copilot-vim
          coc-tabnine
          vim-monokai-pro
          # vim-wakatime
        ];
        extraConfig = ''
          " space key as Leader
          nnoremap <Space> <Nop>
          let g:mapleader = "\<Space>"

          " non-yank delete
          nnoremap <leader>d "_d
          xnoremap <leader>d "_d

          " which-key config
          "nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

          " line numbers
          set number

          " indentation config
          set expandtab
          set tabstop=4
          set shiftwidth=4
        '';
      };

      home.file.".Xmodmap".text = ''
        keycode 66 = Hyper_L

        clear lock
        clear mod3
        clear mod4

        add mod3 = Hyper_L
        add mod4 = Super_L Super_R
      '';

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

      # Config files
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

    };

  };
}
