{ config, lib, pkgs, ... }: {
  options.programs.claude-hooks.enableCwdDirenv = lib.mkEnableOption
    "CwdChanged hook that auto-activates direnv for the new working directory";

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.claude-hooks.enableCwdDirenv)
    {
      # Claude Code's settings.json validator rejects the flat
      # `[{type, command}]` shape even for matcher-less events: every
      # entry must be wrapped as `{matcher, hooks: [...]}`. CwdChanged
      # ignores the matcher at runtime but the schema still requires it,
      # so pass an empty string to match all.
      programs.claude-code.settings.hooks.CwdChanged = lib.mkAfter [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "${pkgs.python3}/bin/python3 ${./cwd-direnv.py}";
              timeout = 15;
            }
          ];
        }
      ];
    };
}
