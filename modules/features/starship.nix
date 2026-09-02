_: {
  flake.homeModules.starship = _: {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        directory.truncate_to_repo = false;

        # Explicit format -- only these modules render
        format = "\${env_var.shell_name}\${custom.ssh}$username$hostname$directory$git_branch$git_status$python$cmd_duration$line_break$jobs$character";

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

        # Tag for shells that swap in their own environment (nix devshells and friends,
        # which hardcode PS1); such a shell opts in by exporting the var itself.
        # Parens escaped: ( ) delimits a conditional group in starship's format grammar.
        env_var.shell_name = {
          variable = "CUSTOM_SHELL_NAME";
          format = "[\\($env_value\\)]($style) ";
          style = "bold red";
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
