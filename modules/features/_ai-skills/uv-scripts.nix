{ config, lib, ... }: {
  config = lib.mkIf config.programs.claude-code.enable {
    programs.claude-code.skills.uv-scripts = ./uv-scripts;
  };
}
