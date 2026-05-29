{ config, lib, ... }: {
  options.programs.ai-skills.enableHumanizer = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      humanizer skill (remove signs of AI-generated writing). On by default in
      the opinionated baseline.
    '';
  };

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.ai-skills.enableHumanizer)
    {
      programs.claude-code.skills.humanizer = ./humanizer;
    };
}
