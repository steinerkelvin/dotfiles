{ config, lib, ... }: {
  config = lib.mkIf config.programs.claude-code.enable {
    programs.claude-code.skills.direnv-layout-uv = ./direnv-layout-uv;
  };
}
