# Reusable home-manager module: directory-scoped git identity override.
#
# homeModules.identity sets one personal user.name/email globally. This layers
# a git `includeIf "gitdir:<path>"` on top so repos under a given directory
# (e.g. a work checkout tree) pick up a different email/name instead, without
# touching per-repo `.git/config`. Disabled by default -- a host opts in and
# supplies the path + email:
#
#   imports = [ inputs.kelvin-dotfiles.homeModules.work-identity ];
#   features.work-identity = {
#     enable = true;
#     path = "~/work/";
#     email = "kelvin@mixrank.com";
#   };

_:

{
  flake.homeModules.work-identity = { config, lib, ... }:
    let
      cfg = config.features.work-identity;
    in
    {
      options.features.work-identity = {
        enable = lib.mkEnableOption "directory-scoped git identity override";

        path = lib.mkOption {
          type = lib.types.str;
          default = "~/work/";
          description = ''
            Directory prefix (git `includeIf gitdir:` condition) under which
            this identity applies.
          '';
        };

        email = lib.mkOption {
          type = lib.types.str;
          example = "kelvin@mixrank.com";
          description = "git `user.email` to use under `path`.";
        };

        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "git `user.name` override under `path`; null keeps the personal name.";
        };
      };

      config = lib.mkIf cfg.enable {
        programs.git.includes = [
          {
            condition = "gitdir:${cfg.path}";
            contents.user = { email = cfg.email; } // lib.optionalAttrs (cfg.name != null) {
              name = cfg.name;
            };
          }
        ];
      };
    };
}
