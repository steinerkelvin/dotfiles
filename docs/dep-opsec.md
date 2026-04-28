# dep-opsec

Supply-chain release-age cooldown defaults across bun, npm, pnpm, yarn, uv, and deno. The module writes the configs whether or not these binaries are present. Default 7 days. Refuses installs of versions younger than the threshold; falls back to the next-oldest in ranges. (`base-dev` only installs `nodejs`, `bun`, and `uv` itself; pnpm/yarn/deno are out of its scope. The configs still apply if you bring them in by other means.)

## Threat model

Smash-and-grab attacks where an attacker compromises a maintainer or registry credential, publishes a malicious version, and milks installs in the first hours before takedown. A 7-day cooldown would have blocked installs in 11 of 21 publicly reported 2018-2026 incidents and narrowed the exposure window in 2 more.

What this is **not** a defence against:
- Long-running infiltration (XZ-style)
- Build-system compromise
- CDN / domain takeover
- Maintainer sabotage
- Plain CVEs in legitimate code

Cooldown is one layer. Pair with lockfile enforcement, SHA-pinned actions, `--ignore-scripts` allowlists, and behavioural scanners.

## Enable

```nix
imports = [ inputs.kelvin-dotfiles.homeModules.dep-opsec ];
features.dep-opsec.enable = true;
```

`base-dev` already imports this and sets `features.dep-opsec.enable = true`, so importing `base-dev` is enough. If you import `dep-opsec` directly without `base-dev`, set `enable = true` yourself.

## Options

| Option | Type | Default | Notes |
|---|---|---|---|
| `features.dep-opsec.enable` | bool | `false` | Master switch. |
| `features.dep-opsec.cooldownDays` | int | `7` | Per-ecosystem options derive from this. |
| `features.dep-opsec.bun.enable` | bool | `true` | Writes `~/.bunfig.toml`. |
| `features.dep-opsec.bun.minimumReleaseAge` | int | `cooldownDays * 86400` | Seconds. |
| `features.dep-opsec.bun.ignoreScripts` | bool | `false` | Opt-in. Disables postinstall/preinstall scripts globally. Bun supports `[trustedDependencies]`; you must enumerate each package that legitimately needs scripts. Off by default because the migration cost is non-trivial. |
| `features.dep-opsec.npm.enable` | bool | `true` | Writes `~/.npmrc` (npm 11.10+; pnpm respects the same key). |
| `features.dep-opsec.npm.releaseAgeDays` | int | `cooldownDays` | Days. |
| `features.dep-opsec.npm.exclude` | list[str] | `[]` | Packages exempted from the cooldown (`minimum-release-age-exclude`). |
| `features.dep-opsec.pnpm.enable` | bool | `true` | Writes the snippet (see pnpm caveat below). |
| `features.dep-opsec.pnpm.minimumReleaseAgeMinutes` | int | `cooldownDays * 1440` | Minutes. |
| `features.dep-opsec.pnpm.ignoreScripts` | bool | `false` | Opt-in. Appends `ignore-scripts = true` to `~/.npmrc`. pnpm supports `onlyBuiltDependencies`. |
| `features.dep-opsec.yarn.enable` | bool | `true` | Writes `~/.yarnrc.yml` (yarn 4.10+). |
| `features.dep-opsec.yarn.npmMinimalAgeGate` | str | `"<N>d"` | Yarn duration string. |
| `features.dep-opsec.uv.enable` | bool | `true` | Writes `~/.config/uv/uv.toml`. |
| `features.dep-opsec.uv.excludeNewer` | str | `"<N>days"` | Relative duration or ISO-8601 timestamp. |
| `features.dep-opsec.deno.enable` | bool | `true` | Installs a zsh wrapper. |
| `features.dep-opsec.deno.minimumDependencyAge` | str | `"<N>d"` | Deno duration string. |

## Files written to `$HOME`

- `~/.bunfig.toml` -- `[install] minimumReleaseAge = <seconds>`
- `~/.npmrc` -- `min-release-age = <days>` (+ `minimum-release-age-exclude` and `ignore-scripts` when set)
- `~/.yarnrc.yml` -- `npmMinimalAgeGate: "<duration>"`
- `~/.config/uv/uv.toml` -- `exclude-newer = "<value>"`
- `~/.config/pnpm/dep-opsec.snippet.yaml` -- snippet for per-project use; see below
- `programs.zsh.initContent` -- a `deno()` shell function injecting `--minimum-dependency-age` into `deno install`, `deno outdated`, and `deno update` (other subcommands pass through unchanged)

## pnpm caveat

pnpm has no global `minimumReleaseAge` as of 2026-04. The module ships a snippet at `~/.config/pnpm/dep-opsec.snippet.yaml`:

```yaml
minimumReleaseAge: 10080
```

Paste it into each project's `pnpm-workspace.yaml` (pnpm 10.16+). The shared `~/.npmrc` `min-release-age` key covers the bulk of installs in the meantime.

## CVE-bypass cheatsheet

When a real fix lands inside the cooldown window, install with a one-shot bypass:

| Manager | Flag |
|---|---|
| bun | `bun install --no-cooldown <pkg>` |
| npm | `npm install --ignore-min-release-age <pkg>` |
| pnpm | `pnpm install --ignore-min-release-age <pkg>` (or persistent: `minimumReleaseAgeExclude` in `pnpm-workspace.yaml`) |
| yarn | `yarn add --no-min-age-gate <pkg>` |
| uv | `uv add --exclude-newer-package <pkg>=<isoDate>` |
| deno | drop `--minimum-dependency-age` for the one invocation (the wrapper only injects on `install/outdated/update`) |

## Ecosystems with no upstream cooldown primitive

Documented gap, no config written:

- pip -- only `--uploaded-prior-to=<ISO-8601>`, no relative durations
- cargo -- unstable `-Z minimum-update-age`, nightly only
- go, maven, gradle, composer -- nothing upstream
- nix flake -- nothing upstream (flake.lock pins, but no age gate)

GitHub Actions: the analogous control is SHA-pinning third-party actions instead of `@vN` tags. This repo's own `.github/workflows/flake.yml` still uses mutable `@v<N>` tags; an inventory + pinning pass is tracked in issue #6.

## Verify

After `home-manager switch`, the five files listed above should exist with the cooldown values rendered (the `pnpm` snippet is the fifth, alongside the four binary-shipping configs). Smoke-test with a freshly published package:

```sh
tmp=$(mktemp -d) && cd $tmp
cat > package.json <<'EOF'
{"name":"smoke","version":"0.0.0","dependencies":{"next":"16.3.0-canary.3"}}
EOF
bun install --dry-run
# error: No version matching "next" found for specifier "16.3.0-canary.3"
#        (blocked by minimum-release-age: 604800 seconds)

npm install --dry-run
# npm error notarget No matching version found for next@16.3.0-canary.3
#                    with a date before <today minus 7d>.
```

For range-based fallback (no error, picks an older satisfying version):

```sh
cat > package.json <<'EOF'
{"name":"smoke","version":"0.0.0","dependencies":{"axios":"^1.0.0"}}
EOF
bun install --dry-run
# axios@1.15.1            <- skipped 1.15.2 (too fresh)
```

Pick any package whose `latest` is younger than `cooldownDays`; npm/registry's `time` field tells you which.

## Coverage matrix (2026-04-28)

| PM | Fresh-pin block | Range fallback | Notes |
|---|---|---|---|
| bun | live-tested | live-tested | -- |
| npm | live-tested | live-tested | requires npm 11.10+ |
| pnpm | live-tested | live-tested | per-project snippet |
| uv | live-tested | live-tested | requires uv 0.9.17+ for relative durations |
| yarn | config rendered | not live-tested | requires yarn 4.10+ |
| deno | not tested | not tested | wrapper covers `install/outdated/update` only |
