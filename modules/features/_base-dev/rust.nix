{ pkgs, lib, config, ... }:

{
  home.packages = lib.optionals config.k.heavy [
    pkgs.rustup
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
