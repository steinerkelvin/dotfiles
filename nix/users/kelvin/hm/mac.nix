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

  programs.zsh.initExtra = ''
    test -e "/opt/homebrew/bin/brew" && eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
