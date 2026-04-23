# Reusable home-manager module: Claude Code session hooks.
#
# Registers Python hooks under ~/.claude/settings.json for events in the
# Claude Code hooks protocol (https://code.claude.com/docs/en/hooks).
# Per-hook wiring lives in `_claude-hooks/<name>.nix`.
#
# Consumers opt in alongside ai-skills:
#   imports = [ inputs.kelvin-dotfiles.homeModules.claude-hooks ];
#   programs.claude-hooks.enableCwdDirenv = true;
#
# Downstream HM modules can contribute their own hooks by merging into
# `programs.claude-code.settings.hooks.<Event>` — the upstream claude-code
# module writes the result to ~/.claude/settings.json.
#
# Toggles for optional built-ins live under `programs.claude-hooks.*`.

_:

{
  flake.homeModules.claude-hooks = _: {
    imports = [
      ./_claude-hooks/cwd-direnv.nix
    ];
  };
}
