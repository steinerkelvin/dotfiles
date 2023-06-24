{ ... }: 

let
  username = "kelvin";
in
{
	imports = [
    ./common.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "23.05";

  nixpkgs.config.allowUnfree = true;
}
