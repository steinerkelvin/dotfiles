# Reusable home-manager module: AI tooling skills.
# Wires structural-search / code-stats / uv-scripts skill files into
# Claude Code and Codex via path-backed home.file entries, and pulls in
# the corresponding CLI tools when the relevant enableXxx options are set.
#
# This is a personal-tooling layer, not part of the base-dev kernel.
# Consumers opt in alongside base-dev:
#   imports = [ inputs.kelvin-dotfiles.homeModules.base-dev
#               inputs.kelvin-dotfiles.homeModules.ai-skills ];
#
# The option is declared by home-manager.flakeModules.default which is
# imported in the root flake.nix.

{ ... }:

{
  flake.homeModules.ai-skills = ../../nix/home/ai-skills;
}
