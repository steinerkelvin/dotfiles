{ pkgs, ... }:

{
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
