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

{ inputs, ... }:
{
  flake.homeModules.nixvim =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;

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
        };

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
            mode = "n";
            key = "x";
            action = ''"_x'';
            options.desc = "Delete char without clobbering register";
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
        ];

        extraConfigLua = ''
          require("claudecode").setup({
            terminal = {
              provider = "none",
            },
          })
        '';
      };
    };
}
