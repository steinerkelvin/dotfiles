{ config, lib, pkgs, ... }: {
  options.programs.claude-hooks.enableCwdDirenv = lib.mkEnableOption
    "CwdChanged hook that auto-activates direnv for the new working directory";

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.claude-hooks.enableCwdDirenv)
    {
      # CwdChanged does not support matchers (docs: every occurrence fires
      # unconditionally), so the canonical settings shape is a flat list of
      # hook command specs.
      programs.claude-code.settings.hooks.CwdChanged = lib.mkAfter [
        {
          type = "command";
          command = "${pkgs.python3}/bin/python3 ${./cwd-direnv.py}";
          timeout = 15;
        }
      ];
    };
}
