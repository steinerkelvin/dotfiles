# Reusable home-manager module: supply-chain cooldown defaults.
#
# Threat model: smash-and-grab attacks where an attacker compromises a
# maintainer or registry credential, publishes a malicious version, and
# milks installs in the first hours before takedown. A 7-day cooldown
# would have blocked installs in 11 of 21 publicly reported 2018-2026
# incidents and narrowed the exposure window in 2 more.
#
# What this is NOT: defence against long-running infiltration (XZ-style),
# build-system compromise, CDN takeover, maintainer sabotage, or plain
# CVEs in legitimate code. Cooldown is one layer.
#
# CVE-bypass cheatsheet (install-time flags, when a real fix lands inside
# the cooldown window):
#   bun:   bun install --no-cooldown <pkg>
#   npm:   npm install --ignore-min-release-age <pkg>
#   pnpm:  pnpm install --ignore-min-release-age <pkg>
#          (or persistent: minimumReleaseAgeExclude in pnpm-workspace.yaml)
#   yarn:  yarn add --no-min-age-gate <pkg>
#   uv:    uv add --exclude-newer-package <pkg>=<isoDate>
#   deno:  drop --minimum-dependency-age for the one invocation
#
# Ecosystems with no upstream cooldown primitive as of 2026-04
# (documented gap, no config written):
#   pip:       only --uploaded-prior-to=<ISO-8601>, no relative durations
#   cargo:     unstable -Z minimum-update-age, nightly only
#   go:        nothing upstream
#   maven:     nothing upstream
#   gradle:    nothing upstream
#   composer:  nothing upstream
#   nix flake: nothing upstream (flake.lock pins, but no age gate)
#
# GitHub Actions: SHA-pin third-party actions instead of @vN tags. The
# `actions/*` org tags are mutable. Audited in this repo's workflows.
#
# Consumers opt in alongside base-dev:
#   imports = [ inputs.kelvin-dotfiles.homeModules.dep-opsec ];
#   features.dep-opsec.enable = true;

_:

{
  flake.homeModules.dep-opsec = { config, lib, ... }:
    let
      cfg = config.features.dep-opsec;

      cooldownSeconds = cfg.cooldownDays * 24 * 60 * 60;
      cooldownMinutes = cfg.cooldownDays * 24 * 60;
      cooldownDuration = "${toString cfg.cooldownDays}d";

      # Render an .npmrc-style ini line.
      kv = key: value: "${key} = ${toString value}";

      # ~/.npmrc is shared between npm and pnpm: pnpm reads it for
      # almost all install-time config (min-release-age, ignore-scripts).
      # Emit when either ecosystem is enabled, not just npm — otherwise
      # a pnpm-only setup loses its global cooldown + ignoreScripts.
      npmrcWanted = cfg.npm.enable || cfg.pnpm.enable;
      npmrcText =
        let
          minReleaseAgeLine =
            lib.optionalString npmrcWanted
              "${kv "min-release-age" cfg.npm.releaseAgeDays}\n";
          excludeLine =
            lib.optionalString (cfg.npm.enable && cfg.npm.exclude != [ ])
              "minimum-release-age-exclude = ${lib.concatStringsSep "," cfg.npm.exclude}\n";
          ignoreScriptsLine =
            lib.optionalString cfg.pnpm.ignoreScripts "ignore-scripts = true\n";
        in
        lib.optionalString npmrcWanted "# Managed by features.dep-opsec — do not edit by hand.\n"
        + minReleaseAgeLine
        + excludeLine
        + ignoreScriptsLine;

      bunfigText = lib.optionalString cfg.bun.enable (''
        # Managed by features.dep-opsec — do not edit by hand.
        [install]
        minimumReleaseAge = ${toString cfg.bun.minimumReleaseAge}
      '' + lib.optionalString cfg.bun.ignoreScripts ''
        ignoreScripts = true
      '');

      yarnrcText = lib.optionalString cfg.yarn.enable ''
        # Managed by features.dep-opsec — do not edit by hand.
        npmMinimalAgeGate: "${cfg.yarn.npmMinimalAgeGate}"
      '';

      uvTomlText = lib.optionalString cfg.uv.enable ''
        # Managed by features.dep-opsec — do not edit by hand.
        exclude-newer = "${cfg.uv.excludeNewer}"
      '';

      # pnpm-workspace.yaml is per-project; pnpm has no global equivalent
      # for minimumReleaseAge as of 2026-04. We write the setting to the
      # shared ~/.npmrc (npm key minimum-release-age, which pnpm respects
      # for most install-time config) and surface a copy-paste snippet
      # via this file for projects that want the pnpm-native override
      # in pnpm-workspace.yaml.
      pnpmSnippetText = lib.optionalString cfg.pnpm.enable ''
        # Drop into your project's pnpm-workspace.yaml (pnpm 10.16+).
        # Managed by features.dep-opsec.
        minimumReleaseAge: ${toString cfg.pnpm.minimumReleaseAgeMinutes}
      '';

      anyNpmrcWriter = cfg.enable && npmrcWanted;
      anyBunWriter = cfg.enable && cfg.bun.enable;
      anyYarnWriter = cfg.enable && cfg.yarn.enable;
      anyUvWriter = cfg.enable && cfg.uv.enable;
      anyPnpmWriter = cfg.enable && cfg.pnpm.enable;
      anyDenoWriter = cfg.enable && cfg.deno.enable;
    in
    {
      options.features.dep-opsec = {
        enable = lib.mkEnableOption "supply-chain cooldown defaults across package managers";

        cooldownDays = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 7;
          description = ''
            Default cooldown in days. Per-ecosystem options derive from
            this value but can be overridden individually.
          '';
        };

        bun = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Write [install] minimumReleaseAge to ~/.bunfig.toml.";
          };
          minimumReleaseAge = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = cooldownSeconds;
            defaultText = lib.literalExpression "cooldownDays * 86400";
            description = "bunfig.toml [install] minimumReleaseAge in seconds.";
          };
          ignoreScripts = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Opt-in: write ignoreScripts = true to ~/.bunfig.toml.

              Disables postinstall/preinstall lifecycle scripts globally.
              Bun supports a [trustedDependencies] allowlist for packages
              that legitimately need scripts; you must add each one
              explicitly before its scripts will run. Migration cost is
              non-trivial — leave off until you've enumerated the
              packages your projects actually need.
            '';
          };
        };

        npm = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Write min-release-age + minimum-release-age-exclude to ~/.npmrc (npm 11.10+, also respected by pnpm).";
          };
          releaseAgeDays = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = cfg.cooldownDays;
            defaultText = lib.literalExpression "cooldownDays";
            description = "~/.npmrc min-release-age value in days.";
          };
          exclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "@my-org/internal-tool" "lodash" ];
            description = "Packages exempted from the cooldown (minimum-release-age-exclude).";
          };
        };

        pnpm = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Render a pnpm-workspace.yaml snippet to
              ~/.config/pnpm/dep-opsec.snippet.yaml.

              pnpm has no global minimumReleaseAge as of 2026-04;
              the snippet is meant to be pasted into per-project
              pnpm-workspace.yaml. The matching ~/.npmrc key
              (minimum-release-age) covers most installs in the
              meantime.
            '';
          };
          minimumReleaseAgeMinutes = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = cooldownMinutes;
            defaultText = lib.literalExpression "cooldownDays * 1440";
            description = "pnpm-workspace.yaml minimumReleaseAge value in minutes (pnpm 10.16+).";
          };
          ignoreScripts = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Opt-in: append ignore-scripts = true to ~/.npmrc, which
              pnpm respects.

              Disables postinstall/preinstall lifecycle scripts globally.
              pnpm supports onlyBuiltDependencies in pnpm-workspace.yaml
              as the trusted-dependency allowlist; you must enumerate
              each package that legitimately needs scripts. Migration
              cost is non-trivial — leave off until that list is
              compiled.
            '';
          };
        };

        yarn = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Write npmMinimalAgeGate to ~/.yarnrc.yml (yarn 4.10+).";
          };
          npmMinimalAgeGate = lib.mkOption {
            type = lib.types.str;
            default = cooldownDuration;
            defaultText = lib.literalExpression "(toString cooldownDays) + \"d\"";
            description = "Yarn duration string, e.g. \"7d\".";
          };
        };

        uv = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Write [tool.uv] exclude-newer to ~/.config/uv/uv.toml.";
          };
          excludeNewer = lib.mkOption {
            type = lib.types.str;
            default = "${toString cfg.cooldownDays}days";
            defaultText = lib.literalExpression "(toString cooldownDays) + \"days\"";
            example = "2026-04-20T00:00:00Z";
            description = ''
              uv exclude-newer value. Accepts a relative duration
              (e.g. "7days") or an ISO-8601 timestamp.
            '';
          };
        };

        deno = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Install a zsh wrapper that injects
              --minimum-dependency-age into deno install/add/cache/
              outdated/update invocations.
            '';
          };
          minimumDependencyAge = lib.mkOption {
            type = lib.types.str;
            default = cooldownDuration;
            defaultText = lib.literalExpression "(toString cooldownDays) + \"d\"";
            description = "Deno --minimum-dependency-age duration, e.g. \"7d\".";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        home.file = lib.mkMerge [
          (lib.mkIf anyNpmrcWriter {
            ".npmrc".text = npmrcText;
          })
          (lib.mkIf anyBunWriter {
            ".bunfig.toml".text = bunfigText;
          })
          (lib.mkIf anyYarnWriter {
            ".yarnrc.yml".text = yarnrcText;
          })
          (lib.mkIf anyUvWriter {
            ".config/uv/uv.toml".text = uvTomlText;
          })
          (lib.mkIf anyPnpmWriter {
            ".config/pnpm/dep-opsec.snippet.yaml".text = pnpmSnippetText;
          })
        ];

        programs.zsh.initContent = lib.mkIf anyDenoWriter (lib.mkAfter ''
          # features.dep-opsec: inject --minimum-dependency-age into the
          # deno subcommands that documented it as of 2026-04 (install,
          # outdated, update). Walk past leading global flags so
          # invocations like `deno --quiet install …` or
          # `deno --config foo.json update …` still get the gate.
          # --log-level / --config / --seed take a separate value arg,
          # so we skip one extra token after them. Other subcommands
          # (run, fmt, lint, cache, add, …) pass through untouched.
          deno() {
            local pre=() rest=() skip_next=0 hit=0
            local arg
            for arg in "$@"; do
              if [ $hit -ne 0 ]; then
                rest+=("$arg")
                continue
              fi
              pre+=("$arg")
              if [ $skip_next -eq 1 ]; then
                skip_next=0
                continue
              fi
              case "$arg" in
                --log-level|--config|--seed) skip_next=1 ;;
                -*) ;;
                install|outdated|update) hit=1 ;;
                *) hit=2 ;;
              esac
            done
            if [ $hit -eq 1 ]; then
              command deno "''${pre[@]}" \
                --minimum-dependency-age=${cfg.deno.minimumDependencyAge} \
                "''${rest[@]}"
            else
              command deno "$@"
            fi
          }
        '');
      };
    };
}
