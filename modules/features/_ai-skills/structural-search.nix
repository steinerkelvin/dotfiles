{ config, lib, pkgs, ... }: {
  options.programs.ai-skills.enableStructuralSearch = lib.mkEnableOption
    "structural code search skill and tools (ast-grep, comby, tree-sitter)";

  config = lib.mkIf
    (config.programs.claude-code.enable
      && config.programs.ai-skills.enableStructuralSearch)
    {
      programs.claude-code.skills.structural-search = ./structural-search;
      home.packages = [
        pkgs.ast-grep
        # pkgs.comby # broken in current nixpkgs
        pkgs.tree-sitter
      ];
    };
}
