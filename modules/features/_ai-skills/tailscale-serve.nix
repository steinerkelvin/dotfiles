{ config, lib, ... }: {
  options.programs.ai-skills.enableTailscaleServe = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      tailscale-serve skill (serve files, directories, or git diffs over
      Tailscale HTTPS). On by default in the opinionated baseline.
    '';
  };

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.ai-skills.enableTailscaleServe)
    {
      programs.claude-code.skills.tailscale-serve = ./tailscale-serve;
    };
}
