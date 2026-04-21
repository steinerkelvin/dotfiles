# Reusable home-manager module: AI tooling skills.
#
# Wires skill primers into Claude Code and Codex, and pulls in the CLI
# tools paired with each skill. Per-skill configuration lives alongside
# each skill in `_ai-skills/<skill>.nix`.
#
# Consumers opt in alongside base-dev:
#   imports = [ inputs.kelvin-dotfiles.homeModules.base-dev
#               inputs.kelvin-dotfiles.homeModules.ai-skills ];
#
# Downstream HM modules can contribute their own skills; the attrset
# merge flows through to both Claude and Codex:
#   programs.claude-code.skills.<name> = <path>;
#
# Toggles for optional built-ins live under `programs.ai-skills.*`.

_:

{
  flake.homeModules.ai-skills = { config, lib, ... }: {
    imports = [
      ./_ai-skills/uv-scripts.nix
      ./_ai-skills/direnv-layout-uv.nix
      ./_ai-skills/structural-search.nix
      ./_ai-skills/code-stats.nix
    ];

    config = lib.mkIf config.programs.claude-code.enable {
      # Codex loads skills the same way as Claude Code. Mirror the final
      # merged set (built-ins + downstream contributions) into ~/.codex/skills.
      home.file = lib.mapAttrs'
        (name: source: {
          name = ".codex/skills/${name}";
          value.source = source;
        })
        config.programs.claude-code.skills;
    };
  };
}
