# Reusable home-manager feature module: nixvim-backed Neovim setup with
# coder/claudecode.nvim wired in. Opt-in only -- NOT imported by base-dev.
#
# Coexists at-rest with the legacy programs.neovim config in
# profiles/kelvin/apps/nvim/. Activate exactly one of them per profile;
# both produce $HOME/.nix-profile/bin/nvim and home-manager will fail
# on the collision.
#
# External consumers:
#   imports = [ inputs.dotfiles.homeModules.nixvim ];
#
# Requires the `claude` CLI on PATH for claudecode.nvim. Castle/profiles
# already provision it; this module deliberately does not duplicate.
#
# Deliberately NOT carried over from the legacy config (decided 2026-09-02,
# when the port gaps were audited): copilot-lua (claudecode.nvim covers the
# AI layer), vim-wakatime, nvim-tree + the netrw-disable globals, and
# telescope-zoxide (shell zoxide via modules/features/zoxide.nix stays).
# leap-nvim was replaced by flash.nvim, not dropped.

{ inputs, ... }:
{
  flake.homeModules.nixvim =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;

        # Reuse home-manager's pkgs instead of letting nixvim import its own
        # nixpkgs (its default is useGlobalPackages = false, i.e. a second
        # independent instantiation). One nixpkgs eval instead of two, and it
        # drops the "Nixvim's inputs pin Nixpkgs to <rev>" warning at the
        # root rather than waiving it: with pkgs supplied, nixvim never
        # consults nixpkgs.source at all. Upstream asserts nixvim's own
        # nixpkgs.overlays/config are empty -- we set neither.
        nixpkgs.useGlobalPackages = true;

        globals.mapleader = " ";
        globals.maplocalleader = " ";

        opts = {
          number = true;
          relativenumber = true;
          termguicolors = true;
          expandtab = true;
          tabstop = 4;
          shiftwidth = 4;
          # Intentionally NOT setting clipboard = "unnamedplus".
          # Use cp / cv mappings below for explicit system-clipboard ops.

          # Pick up files changed on disk (eg by p9 sync) without prompting.
          # Needs the checktime autocmd below to actually fire -- autoread
          # alone only re-reads when vim happens to notice.
          autoread = true;
        };

        autoCmd = [
          {
            event = [
              "FocusGained"
              "BufEnter"
              "CursorHold"
              "CursorHoldI"
            ];
            command = "checktime";
          }
        ];

        # Clipboard ergonomics: explicit only, no global unnamedplus.
        # Reflex tip: `"0p` pastes the most recent yank, surviving any
        # subsequent delete that overwrote the unnamed register.
        keymaps = [
          {
            mode = [
              "n"
              "v"
            ];
            key = "cp";
            action = ''"+y'';
            options.desc = "Copy to system clipboard";
          }
          {
            mode = [
              "n"
              "v"
            ];
            key = "cv";
            action = ''"+p'';
            options.desc = "Paste from system clipboard";
          }
          {
            mode = [
              "n"
              "x"
            ];
            key = "<leader>y";
            action = ''"*y'';
            options.desc = "Yank to terminal clipboard (OSC 52)";
          }
          {
            mode = "n";
            key = "x";
            action = ''"_x'';
            options.desc = "Delete char without clobbering register";
          }
          {
            mode = [
              "n"
              "v"
            ];
            key = "<leader>d";
            action = ''"_d'';
            options.desc = "Delete without clobbering register";
          }

          # claudecode.nvim keymaps (the README suggests these but does
          # not ship them by default).
          {
            mode = "n";
            key = "<leader>ac";
            action = "<cmd>ClaudeCode<cr>";
            options.desc = "Toggle Claude";
          }
          {
            mode = "n";
            key = "<leader>af";
            action = "<cmd>ClaudeCodeFocus<cr>";
            options.desc = "Focus Claude";
          }
          {
            mode = "n";
            key = "<leader>ar";
            action = "<cmd>ClaudeCode --resume<cr>";
            options.desc = "Resume Claude session";
          }
          {
            mode = "n";
            key = "<leader>aC";
            action = "<cmd>ClaudeCode --continue<cr>";
            options.desc = "Continue Claude session";
          }
          {
            mode = "n";
            key = "<leader>am";
            action = "<cmd>ClaudeCodeSelectModel<cr>";
            options.desc = "Select Claude model";
          }
          {
            mode = "n";
            key = "<leader>ab";
            action = "<cmd>ClaudeCodeAdd %<cr>";
            options.desc = "Add current buffer to Claude context";
          }
          {
            mode = "v";
            key = "<leader>as";
            action = "<cmd>ClaudeCodeSend<cr>";
            options.desc = "Send selection to Claude";
          }
          {
            mode = "n";
            key = "<leader>aa";
            action = "<cmd>ClaudeCodeDiffAccept<cr>";
            options.desc = "Accept Claude diff";
          }
          {
            mode = "n";
            key = "<leader>ad";
            action = "<cmd>ClaudeCodeDiffDeny<cr>";
            options.desc = "Reject Claude diff";
          }

          # flash.nvim keymaps. NOTE: s/S take over vim's substitute -- this is
          # intentional and redundant (s == cl, S == cc). __raw lua-function
          # form because <cmd>...<cr> doesn't work in cmdline mode (<c-s>).
          {
            mode = [
              "n"
              "x"
              "o"
            ];
            key = "s";
            action.__raw = "function() require('flash').jump() end";
            options.desc = "Flash jump";
          }
          {
            mode = [
              "n"
              "x"
              "o"
            ];
            key = "S";
            action.__raw = "function() require('flash').treesitter() end";
            options.desc = "Flash treesitter";
          }
          {
            mode = "o";
            key = "r";
            action.__raw = "function() require('flash').remote() end";
            options.desc = "Flash remote";
          }
          {
            mode = [
              "o"
              "x"
            ];
            key = "R";
            action.__raw = "function() require('flash').treesitter_search() end";
            options.desc = "Flash treesitter search";
          }
          {
            mode = "c";
            key = "<c-s>";
            action.__raw = "function() require('flash').toggle() end";
            options.desc = "Toggle flash in search";
          }
        ];

        plugins.treesitter = {
          enable = true;
          nixGrammars = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            nix
            lua
            python
            markdown
            markdown_inline
            typescript
            tsx
            rust
            bash
            json
            yaml
            toml
          ];
        };

        plugins.lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
            pyright.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            ts_ls.enable = true;
          };
        };

        plugins.which-key.enable = true;
        plugins.web-devicons.enable = true;
        plugins.nvim-surround.enable = true;

        # flash.nvim: jump-anywhere motion. Defaults call setup() and enable
        # the f/t/F/T multi-line enhancement. Jump keymaps are added below.
        plugins.flash.enable = true;

        plugins.telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fb" = "buffers";
            "<leader>fh" = "help_tags";
            "<leader>fr" = "oldfiles";
            "<leader>fs" = "grep_string";
            "<leader>fd" = "diagnostics";
            "<leader>fc" = "commands";
            "<leader>fk" = "keymaps";
          };

          # Make find_files / live_grep follow symlinks and bypass
          # gitignore. Needed for setups like ~/kspace where the entry
          # points to actual code are symlinks inside a gitignored
          # `repos/` directory. Common noise dirs are explicitly
          # excluded via globs so the listings stay usable.
          settings.defaults.vimgrep_arguments = [
            "${pkgs.ripgrep}/bin/rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--follow"
            "--hidden"
            "--no-ignore-vcs"
            "--glob=!**/.git/**"
            "--glob=!**/node_modules/**"
            "--glob=!**/target/**"
            "--glob=!**/.direnv/**"
            "--glob=!**/.venv/**"
            "--glob=!**/__pycache__/**"
            "--glob=!**/result"
          ];
          settings.pickers.find_files = {
            find_command = [
              "${pkgs.ripgrep}/bin/rg"
              "--files"
              "--follow"
              "--hidden"
              "--no-ignore-vcs"
              "--glob=!**/.git/**"
              "--glob=!**/node_modules/**"
              "--glob=!**/target/**"
              "--glob=!**/.direnv/**"
              "--glob=!**/.venv/**"
              "--glob=!**/__pycache__/**"
              "--glob=!**/result"
            ];
          };
        };

        # claudecode.nvim is in nixpkgs 25.11. To bump past the pin, see
        # the overrideAttrs recipe in ~/.claude/plans/lazy-doodling-yao.md.
        # Using provider = "none": user launches claude in their own
        # tmux/kitty pane and the CLI auto-connects to nvim's MCP server
        # via the lock file. nvim doesn't manage a terminal at all.
        # No need for snacks.nvim (which only matters for "auto"/"snacks"
        # floating-window providers).
        extraPlugins = with pkgs.vimPlugins; [
          claudecode-nvim
          kitty-scrollback-nvim
        ];

        extraConfigLua = ''
          -- OSC 52 clipboard provider, scoped to the "*" register only.
          -- "+" keeps whatever native provider exists (cp/cv above), so
          -- <leader>y works over ssh/tmux where there is no local X/wayland
          -- selection to talk to. Set here rather than via `globals.clipboard`
          -- because the table holds lua functions from the osc52 module.
          local osc52 = require("vim.ui.clipboard.osc52")
          vim.g.clipboard = {
            name = "OSC52-star-only",
            copy = { ["*"] = osc52.copy("*") },
            paste = { ["*"] = osc52.paste("*") },
          }

          require("claudecode").setup({
            terminal = {
              provider = "none",
            },
          })
        '';
      };

      # Bridge for kitty-scrollback.nvim: kitty.conf references the plugin's
      # python kitten by absolute path, but the plugin lives at a versioned nix
      # store path. Generate an include file with the interpolated path (kept
      # version-coherent with the kitty-scrollback-nvim extraPlugins entry
      # above); the kitty module (modules/features/kitty.nix) `include`s this.
      # Generation stays here so the path tracks the plugin version used by
      # nixvim. ~/.config/kitty is a real dir, so this sibling file sits next to
      # the home-manager-generated kitty.conf without collision.
      home.file.".config/kitty/kitty-scrollback.conf".text = ''
        action_alias kitty_scrollback_nvim kitten ${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py
        map kitty_mod+h kitty_scrollback_nvim
        map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
        mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
      '';
    };
}
