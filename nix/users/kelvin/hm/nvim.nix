{ pkgs, ... }:

{
  # Vim

  programs.neovim = {
    enable = true;
    # coc = { enable = true; };
    plugins = let vp = pkgs.vimPlugins; in [
      vp.which-key-nvim

      vp.nvim-tree-lua
      vp.telescope-zoxide

      vp.nvim-treesitter.withAllGrammars
      vp.nvim-lspconfig

      vp.copilot-lua

      vp.monokai-pro-nvim

      # vp.Coqtail

      # vp.yankring
      # vp.vim-easymotion
      # vp.vim-multiple-cursors
      # vp.vim-wakatime
    ];
    extraConfig = ''
      " line numbers
      set number

      " indentation config
      set expandtab
      set tabstop=4
      set shiftwidth=4

      " load lua config
      lua << EOF
        ${builtins.readFile ./nvim.lua}
      EOF
    '';
  };

}
