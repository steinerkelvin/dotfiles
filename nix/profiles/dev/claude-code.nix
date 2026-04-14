{ pkgs, lib, config, ... }:

let
  cfg = config.programs.claude-code;
in
{
  options.programs.claude-code = {
    enableStructuralSearch = lib.mkEnableOption "structural code search skill and tools (ast-grep, comby, tree-sitter)";
    enableCodeStats = lib.mkEnableOption "code statistics skill and tools (tokei, scc)";
  };

  config = lib.mkIf cfg.enable {
    # Claude Code currently loads skills from directory-backed entries such as
    # .claude/skills/<name>/SKILL.md. Using path values here makes Home Manager
    # emit that layout instead of standalone .md files.
    programs.claude-code.skills = lib.mkMerge [
      {
        uv-scripts = ./claude-skills/uv-scripts;
      }

      (lib.mkIf cfg.enableStructuralSearch {
        structural-search = ./claude-skills/structural-search;
      })

      (lib.mkIf cfg.enableCodeStats {
        code-stats = ./claude-skills/code-stats;
      })
    ];

    home.packages =
      lib.optionals cfg.enableStructuralSearch [
        pkgs.ast-grep
        # pkgs.comby # broken in current nixpkgs
        pkgs.tree-sitter
      ] ++ lib.optionals cfg.enableCodeStats [
        pkgs.tokei
        pkgs.scc
      ];
  };
}
