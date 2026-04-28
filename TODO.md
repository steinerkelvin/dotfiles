# TODO

## Nix

- [ ] Measure eval / build times for `dev` closure
- [ ] Add real Darwin CI coverage; current GitHub Actions `--all-systems` pass is eval-only

## Supply-chain (dep-opsec follow-ups)

- [ ] SHA-pin third-party GitHub Actions in `.github/workflows/flake.yml`
      (`actions/checkout`, `DeterminateSystems/{flake-checker,nix-installer,magic-nix-cache}-action`).
      Mutable `@vN` tags are the analog of npm cooldown gaps for CI.
- [ ] Re-verify npm cooldown enforcement after the next nixpkgs node bump.
      As of nixpkgs 25.11 npm ships at `10.9.7`; the `min-release-age` key is
      written to `~/.npmrc` and recognised (`npm config get` reads it) but
      enforcement only landed in npm `11.10+`. No module change needed once
      nixpkgs catches up.
- [ ] Revisit `features.dep-opsec.bun.ignoreScripts` and `pnpm.ignoreScripts`
      once the trustedDependencies / onlyBuiltDependencies allowlists for our
      projects are enumerated.
- [ ] Track upstream cargo `-Z minimum-update-age` stabilisation and wire a
      `features.dep-opsec.cargo` knob when it lands on stable.
- [ ] Audit Nix flake input pinning (separate decision from cooldown — track
      whether an age-gate primitive ever materialises upstream).

## Momo Server

- [ ] Setup Linux machine
- [ ] Configure Home Assistant
- [ ] Configure Smokeping

## Nix Experiments

- [ ] test `lorri` (https://github.com/nix-community/lorri)

## Dotfiles Improvements

- [ ] utility script to move a file to dotfiles/home at the equivalent path and link back to home
  - Move a file from ~/path/to/file to ~/dotfiles/home/path/to/file
  - Commit the change to git
  - Create symlink back to original location using homeshick

## MacOS

- Swap Ctrl <-> Fn on built-in keyboard

## Considering

### Theming on Linux

- Implement consistent theming across Nix/i3/Qt/GTK
- Look into qt5ct for Qt theming configuration
- Consider Kvantum for advanced Qt styling
- Ensure consistent dark/light mode switching

### From Old Scripts Review

#### CLI Tools to Check

- git-extras - additional Git commands
- clac - command-line calculator
- ✓ watch - execute commands periodically (added to packages.nix)
- ✓ imagemagick - image manipulation (already installed in packages.nix)
- ngrok - localhost tunneling
- android-platform-tools - ADB and other Android tools
- dvtm - terminal window manager (pairs well with abduco)

#### Vim/Neovim Plugins

- ✓ leap.nvim - modern alternative to vim-easymotion for fast cursor movement
- vim-multiple-cursors - multiple selection editing (consider alternatives)
- ✓ vim-wakatime - time tracking for coding
- ✓ nvim-surround - text object manipulation

#### Tab Completion Behavior (Fixed)

- ✓ Fixed non-yank delete mapping in `profiles/kelvin/apps/nvim/config.lua` (`<space>d`) for both normal and visual modes
- Consider adapting smart tab completion logic from old init.vim:
  - Uses Tab to navigate completion menu when open
  - Inserts tab when appropriate (after space)
  - Opens completion menu otherwise

### Future Considerations

#### Linting and Code Quality

- Consider adding textlint for Markdown linting in the development environment

#### Keyboard Configuration (On Hold)

- Review keyd.nix~ and old/keyd/default.conf
- Integrate keyboard remapping solution across Linux configurations
- Decide whether to implement as a NixOS module or use existing solutions

### Atuin History Management

- Improve k-atuin-clean functionality:
  - Enhance similarity detection for better typo identification
  - Implement command context tracking
  - Add temporal analysis to identify obsolete commands

### Old Files to Process

- Review and clean up remaining files in old/ directory:
  - ✓ old/arch/ scripts (removed)
  - old/keyd/ directory (potentially integrate into newer configs)
  - ✓ old/init.vim (useful plugins migrated: leap.nvim, vim-wakatime, nvim-surround)
  - old/.Xmodmap, old/.gitconfig, old/.xinitrc, old/.zshrc (review and remove if outdated)
- Review old-brew.sh and make sure all needed packages are in my-brew-formulae.sh
