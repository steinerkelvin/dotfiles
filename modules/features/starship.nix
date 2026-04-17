_: {
  flake.homeModules.starship = _: {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        directory.truncate_to_repo = false;

        # Explicit format -- only these modules render
        format = "\${custom.ssh}$username$hostname$directory$git_branch$git_status$python$cmd_duration$line_break$jobs$character";

        # Username + hostname: SSH sessions only
        username = {
          show_always = false;
          format = "[$user]($style)@";
        };
        hostname = {
          ssh_only = true;
          format = "[$hostname]($style) ";
        };

        # Git branch: not bold
        git_branch.style = "purple";

        # Git status: no brackets, not bold, yellow
        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "yellow";
        };

        # SSH indicator
        custom.ssh = {
          when = "test -n \"$SSH_CONNECTION\"";
          format = "[$symbol]($style) ";
          symbol = "⇄";
          style = "bold blue";
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
