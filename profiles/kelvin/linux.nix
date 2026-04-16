_:

let
  username = "kelvin";
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };
}
