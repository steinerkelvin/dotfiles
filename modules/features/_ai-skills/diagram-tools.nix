{ config, lib, pkgs, ... }: {
  options.programs.ai-skills.enableDiagramTools = lib.mkEnableOption
    "diagram-as-code reference skill and tools (d2, graphviz; kroki via HTTP)";

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.ai-skills.enableDiagramTools)
    {
      programs.claude-code.skills.diagram-tools = ./diagram-tools;
      home.packages = [
        pkgs.d2
        pkgs.graphviz
        pkgs.structurizr-cli
      ];
    };
}
