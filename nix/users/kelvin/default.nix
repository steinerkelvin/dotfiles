{ lib, config, pkgs, inputs, ... }:

let
  username = "kelvin";
  shellScripts = import ./shell {};
  unstable = (import inputs.unstable { system = pkgs.system; });

in {
  imports = [ ./graphical.nix ];

  config = {

    # TODO: integrate this better on separate module
    modules.services.spotifyd.enable = true;

    # TODO: separate user module for shell
    programs.zsh.enable = true;

    users.users."${username}" = {
      isNormalUser = true;
      description = "Kelvin";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
      packages = with pkgs; [ firefox kate ];
    };

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

      # TODO: conditional on existance
      home.sessionPath = [
        "$HOME/.mix/escripts"
      ];

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

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
        # zsh
        # zsh-autosuggestions
        # zsh-syntax-highlighting
        # starship
        zoxide
        nerdfonts

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
        jq
        tmux
        tmate

        # Editors
        vim
        helix

        # Utilities
        pdftk

        # Dev
        tig
        ## Package managers
        yarn
        nodejs
        ## Language managers
        rustup
        # haskellPackages.ghcup

        python310
        python310Packages.ipython
        # ihaskell
      ];

      # Zsh

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh = {
        # vim mode?
        enable = true;
        shellAliases = {
          # Shell aliases
          rmr = "rm -r";
          dusm = "du -hs";
          # Nix aliases
          nxs = "nix-shell --command zsh";
          # Exa aliases
          ll = "exa -l";
          la = "exa -l -a";
          # Git aliases
          glogh = "git log --oneline --decorate --graph HEAD";
          # Kitty aliases
          sshk = "kitty +kitten ssh";
          icatk = "kitty +icat";
          # Homesick/Homeshick aliases
          dtcd = "homeshick cd dotfiles; cd home;";
        };

        oh-my-zsh = {
          enable = true;
          plugins = [
            "sudo"
            "command-not-found"
            "zoxide"
            "git"
            "fzf"
            "rust"
            "pip"
            "yarn"
          ];
        };
      };

      # home.file.".zshrc".text = ''
      #   # Load Antigen
      #   source ${pkgs.antigen}/share/antigen/antigen.zsh
      #   # Set up Antigen to use oh-my-zsh's library
      #   #antigen use oh-my-zsh
      #   # Load the plugins
      #   antigen bundle git
      #   # TODO:
      #   antigen bundle zsh-users/zsh-autosuggestions
      #   antigen bundle zsh-users/zsh-syntax-highlighting
      #   # Apply the settings
      #   antigen apply
      #   # TODO: custom scripts
      #   ''
      #   + (
      #     lib.lists.foldl'
      #       (a: b: a+b)
      #       ""
      #       (lib.attrValues shellScripts)
      #     )
      #   ;

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

      # Helix
      programs.helix = {
        enable = true;
        settings = {
          editor.auto-pairs = false;
          editor.file-picker.hidden = false;
        };
      };

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
