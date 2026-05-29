{ config, lib, ... }: {
  options.programs.ai-skills.enableWt = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      wt (worktrunk) skill (manage git worktrees and fan out parallel agents).
      On by default in the opinionated baseline.
    '';
  };

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.ai-skills.enableWt)
    {
      programs.claude-code.skills.wt = ./wt;
    };
}
