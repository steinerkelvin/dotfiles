{ ... }: {
  flake.homeModules.starship = { ... }: {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        directory.truncate_to_repo = false;

        # Explicit format -- only these modules render
        format = "$directory$git_branch$git_status$python$cmd_duration$line_break$jobs$character";

        # Git branch: not bold
        git_branch.style = "purple";

        # Git status: no brackets, not bold, yellow
        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "yellow";
        };

        # Python: venv only, no version, not bold
        python = {
          format = "[($virtualenv)]($style) ";
          style = "cyan";
        };
      };
    };
  };
}
