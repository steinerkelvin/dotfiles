# Reusable home-manager module: personal git identity (who, not how-I-sign).
#
# base-dev enables git but is team-neutral and deliberately sets no name/email.
# This module carries the personal identity so it can be consumed à la carte by
# anything that builds on base-dev -- the dotfiles targets AND external flakes
# (e.g. the castle host configs), instead of each copying the strings.
#
# Signing (the key-bound, host-specific half) lives in homeModules.git-signing,
# not here -- identity is portable and unconditional, signing is not.
#
# Consume:
#   imports = [ inputs.kelvin-dotfiles.homeModules.identity ];

_:

{
  flake.homeModules.identity = {
    programs.git.settings = {
      user.name = "Kelvin Steiner";
      user.email = "me@steinerkelvin.dev";
    };
  };
}
