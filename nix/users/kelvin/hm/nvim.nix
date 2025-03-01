{ pkgs, ... }:

{
  # Vim

  programs.neovim = {
    enable = true;
    # coc = { enable = true; };
    plugins = let vp = pkgs.vimPlugins; in [
      vp.which-key-nvim
      # vp.mini-icons
      vp.nvim-web-devicons

      vp.nvim-tree-lua
      vp.telescope-zoxide

      vp.nvim-treesitter.withAllGrammars
      vp.nvim-lspconfig

      vp.copilot-lua

      vp.monokai-pro-nvim
      
      # Motion plugins (modern alternatives to EasyMotion)
      vp.leap-nvim  # Modern alternative to EasyMotion
      
      # Time tracking
      vp.vim-wakatime
      
      # Text manipulation
      vp.nvim-surround  # For surrounding text objects

      # vp.Coqtail
      # vp.yankring
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
