# TODO

## Dotfiles Improvements

- [ ] utility script to move a file to dotfiles/home at the equivalent path and link back to home
  - Move a file from ~/path/to/file to ~/dotfiles/home/path/to/file
  - Commit the change to git
  - Create symlink back to original location using homeshick

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

- vim-easymotion - fast cursor movement
- vim-multiple-cursors - multiple selection editing
- vim-wakatime - time tracking for coding

#### Tab Completion Behavior

- Consider adapting smart tab completion logic from old init.vim:
  - Uses Tab to navigate completion menu when open
  - Inserts tab when appropriate (after space)
  - Opens completion menu otherwise

#### Useful Scripts

- ✓ `url-decode` and `url-encode` - URL encoding utilities (already in ~/bin)
- ✓ `join-args` - joins command arguments (already in ~/bin)
- ✓ `ln2null` - converts newlines to null characters (already in ~/bin)
- ✓ `docker-cp-from/to-volume` - docker volume utilities (already available in ~/bin/docker-utils/)

### Future Considerations

#### Linting and Code Quality

- Consider adding textlint for Markdown linting in the development environment

#### Keyboard Configuration (On Hold)

- Review keyd.nix~ and old/keyd/default.conf
- Integrate keyboard remapping solution across Linux configurations 
- Decide whether to implement as a NixOS module or use existing solutions

### Atuin History Management

- Implement suggested improvements from scripts/ATUIN.md:
  - Enhance similarity detection for better typo identification
  - Implement command context tracking
  - Add temporal analysis to identify obsolete commands

### Old Files to Process

- Review and clean up remaining files in old/ directory:
  - ✓ old/arch/ scripts (removed)
  - old/keyd/ directory (potentially integrate into newer configs)
  - old/init.vim (migrate any remaining useful configs)
  - old/.Xmodmap, old/.gitconfig, old/.xinitrc, old/.zshrc (review and remove if outdated)
- Review old-brew.sh and make sure all needed packages are in my-brew-formulae.sh