{ lib, pkgs, ... }:

let
  shellScripts = import ../shell {};
in
{
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Enviroment

  home.sessionVariables = {
    EDITOR = "vi -e";
    VISUAL = "hx";
  };

  ## Path / $PATH

  home.sessionPath = [
    "$HOME/.mix/escripts"
  ];
  # TODO: conditional on existance

  # Direnv

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

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
      nxrb = "nixos-rebuild --flake $(realpath ~/dotfiles)";
      sunxrb = "sudo nixos-rebuild --flake $(realpath ~/dotfiles)";
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
      # Editor aliases
      h = "hx .";
    };

    initExtra =
      ''
        # Homeshick
        source "$HOME/.homesick/repos/homeshick/homeshick.sh"

        PATH="~/bin:$PATH"

        # Utility Shell Functions
        function nxr { nix-shell -p $1 --command $1 }
        function dusort { du -h $@ | sort -h }
      ''
      + lib.strings.concatStrings (lib.attrValues shellScripts)
      ;

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
      # TODO:
      # - zsh-users/zsh-autosuggestions
      # - zsh-users/zsh-syntax-highlighting
    };
  };

  # Git

  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    extraConfig = {
      user.name = "Kelvin Steiner";
      user.email = "me@steinerkelvin.dev";
      push.default = "simple";
      pull.ff = "only";
      init.defaultBranch = "master";
      color.ui = true;
    };
    ignores = [
      "~*"
      "*~"
    ];
  };

  # Homeshick

  home.file.".homesick/repos/homeshick".source =
    pkgs.fetchFromGitHub {
      owner = "andsens";
      repo = "homeshick";
      rev = "d44da86740d88c7612133d4452b2e6bf954c4e66";
      sha256 = "LsFtuQ2PNGQuxj3WDzR2wG7fadIsqJ/q0nRjUxteT5I=";
    };

  # Helix

  programs.helix = {
    enable = true;
    settings = {
      editor.auto-pairs = false;
      editor.file-picker.hidden = false;
    };
  };

  # Vim

  programs.neovim = {
    enable = true;
    coc = { enable = true; };
    plugins = let vp = pkgs.vimPlugins; in [
      vp.vim-nix
      vp.yankring
      vp.zoxide-vim
      vp.which-key-nvim
      vp.vim-easymotion
      vp.vim-multiple-cursors
      vp.copilot-vim
      vp.coc-tabnine
      vp.vim-monokai-pro
      # vp.vim-wakatime
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

}
