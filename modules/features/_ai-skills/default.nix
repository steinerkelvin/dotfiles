{ pkgs, lib, config, ... }:

let
  cfg = config.programs.claude-code;
  skillRoot = ./skills;
  sharedSkills = {
    uv-scripts = skillRoot + "/uv-scripts";
    direnv-layout-uv = skillRoot + "/direnv-layout-uv";
    structural-search = skillRoot + "/structural-search";
    code-stats = skillRoot + "/code-stats";
  };
  enabledSharedSkills =
    {
      uv-scripts = sharedSkills.uv-scripts;
      direnv-layout-uv = sharedSkills.direnv-layout-uv;
    }
    // lib.optionalAttrs cfg.enableStructuralSearch {
      structural-search = sharedSkills.structural-search;
    }
    // lib.optionalAttrs cfg.enableCodeStats {
      code-stats = sharedSkills.code-stats;
    };
in
{
  options.programs.claude-code = {
    enableStructuralSearch = lib.mkEnableOption "structural code search skill and tools (ast-grep, comby, tree-sitter)";
    enableCodeStats = lib.mkEnableOption "code statistics skill and tools (tokei, scc)";
  };

  config = lib.mkIf cfg.enable {
    # Claude Code currently loads skills from directory-backed entries such as
    # .claude/skills/<name>/SKILL.md. Using path values here makes Home Manager
    # emit that layout instead of standalone .md files. This module contributes
    # the shared built-ins; downstream HM modules can contribute their own with
    # `programs.claude-code.skills.<name> = <path>;` (attrsOf merge).
    programs.claude-code.skills = enabledSharedSkills;

    # Codex loads skills the same way. Mirror the *final merged* set (built-ins
    # + anything a downstream consumer contributed) into ~/.codex/skills.
    home.file = lib.mapAttrs'
      (name: source: {
        name = ".codex/skills/${name}";
        value.source = source;
      })
      cfg.skills;

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
