{ ... }: 

let
  username = "kelvin";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
}
