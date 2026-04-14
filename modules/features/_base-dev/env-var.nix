{ ... }:

{
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/opt/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
    "$HOME/node_modules/.bin"
    "$HOME/.local/bin"
  ];
}
