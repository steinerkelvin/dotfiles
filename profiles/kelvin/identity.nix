{ lib, ... }:

let
  username = "kelvin";
in
{
  home = {
    username = lib.mkDefault username;
    stateVersion = lib.mkDefault "23.05";
  };

  programs.git.settings = {
    user.name = "Kelvin Steiner";
    user.email = "me@steinerkelvin.dev";
  };
}
