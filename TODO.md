# TODO

## Considering

### Theming on Linux

- Implement consistent theming across Nix/i3/Qt/GTK
- Look into qt5ct for Qt theming configuration
- Consider Kvantum for advanced Qt styling
- Ensure consistent dark/light mode switching

### From Old Scripts Review

#### CLI Tools to Check

- git-extras - additional Git commands
- dtach - terminal session detachment
- clac - command-line calculator
- watch - execute commands periodically
- imagemagick - image manipulation
- ngrok - localhost tunneling
- android-platform-tools - ADB and other Android tools

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

- `url-decode` and `url-encode` - URL encoding utilities
- `join-args` - joins command arguments
- `ln2null` - converts newlines to null characters
- `docker-cp-from/to-volume` - docker volume utilities