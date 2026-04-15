_: {
  flake.homeModules.homeshick = { pkgs, ... }: {
    home.file.".homesick/repos/homeshick".source =
      pkgs.fetchFromGitHub {
        owner = "andsens";
        repo = "homeshick";
        rev = "9768486e513523b1a3f7d3e44954e65eb2f6b979";
        sha256 = "6H0NU0gAX452pTcI4PUV6Amwj954kDdKxnFdeOhJqlY=";
      };

    programs.zsh = {
      shellAliases = {
        dtcd = "homeshick cd dotfiles; cd home;";
      };

      initContent =
        ''
          # Homeshick
          source "$HOME/.homesick/repos/homeshick/homeshick.sh"
        ''
        + builtins.readFile ./_homeshick/dt.sh;
    };
  };
}
