{ config, lib, pkgs, ... }: {
  options.programs.ai-skills.enableCodeStats = lib.mkEnableOption
    "code statistics skill and tools (tokei, scc)";

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.ai-skills.enableCodeStats)
    {
      programs.claude-code.skills.code-stats = ./code-stats;
      home.packages = [
        pkgs.tokei
        pkgs.scc
      ];
    };
}
