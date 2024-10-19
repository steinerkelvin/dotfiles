{ pkgs, ... }:

{
  # Homeshick
  home.file.".homesick/repos/homeshick".source =
    pkgs.fetchFromGitHub {
      owner = "andsens";
      repo = "homeshick";
      rev = "9768486e513523b1a3f7d3e44954e65eb2f6b979";
      sha256 = "6H0NU0gAX452pTcI4PUV6Amwj954kDdKxnFdeOhJqlY=";
    };
}
