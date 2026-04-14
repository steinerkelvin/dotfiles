_:

let
  username = "kelvin";
in
{
  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };
}
