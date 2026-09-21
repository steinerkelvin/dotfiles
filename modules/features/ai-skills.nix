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

{ config, ... }:

let
  k-ai-auth = config.flake.homeModules.k-ai-auth;
in
{
  flake.homeModules.ai-skills = { config, lib, ... }: {
    imports = [
      k-ai-auth
      ./_ai-skills/uv-scripts.nix
      ./_ai-skills/direnv-layout-uv.nix
      ./_ai-skills/structural-search.nix
      ./_ai-skills/code-stats.nix
      ./_ai-skills/diagram-tools.nix
      ./_ai-skills/pix-qr.nix
      ./_ai-skills/humanizer.nix
      ./_ai-skills/tailscale-serve.nix
      ./_ai-skills/wt.nix
    ];

    options.programs.ai-skills.mirrorDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ".codex" ];
      example = [ ".codex" ".claude-personal" ".codex-personal" ];
      description = ''
        Config dirs, relative to $HOME, that receive a copy of the merged
        skill set. `~/.claude` is not listed: the upstream claude-code module
        writes it. Each extra CLI profile (a separate account and history,
        reached through the `claudio` / `codexo` aliases) belongs here, since
        the account is what should differ between profiles, not the skills.
      '';
    };

    config = lib.mkIf config.programs.claude-code.enable {
      # Codex loads skills the same way as Claude Code, and every mirrored
      # profile wants the final merged set (built-ins + downstream
      # contributions), not just the built-ins.
      home.file = lib.listToAttrs (lib.concatMap
        (dir: lib.mapAttrsToList
          (name: source: lib.nameValuePair "${dir}/skills/${name}" { inherit source; })
          config.programs.claude-code.skills)
        config.programs.ai-skills.mirrorDirs);
    };
  };
}
