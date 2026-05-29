---
name: wt
description: Manage git worktrees with worktrunk (`wt`) -- create, switch, list, merge, remove, and fan out parallel agents into isolated worktrees. Use when the user says "make/create a worktree", "use worktrunk", "wt switch", "new isolated checkout", "open a separate worktree", "list/remove/clean up worktrees", "spin up an agent on a branch / in a worktree", "checkout PR in a worktree", "fan out agents", or wants to run multiple Claude/Codex sessions in parallel on the same repo.
allowed-tools:
  - Bash
  - Read
---

# wt (worktrunk)

`wt` is a git worktree manager built for parallel-agent workflows. Address worktrees by branch name, not path.

Full reference: `vault/pages/home-system/worktrunk.md` (in kspace).

## Daily commands

```sh
wt switch -c <branch>          # create branch + worktree, cd in
wt switch <branch>             # switch to existing
wt switch                      # interactive fzf picker
wt switch pr:<n>               # check out PR #n (needs gh)
wt list                        # status: @current ^prev +staged ↑ahead ⇡unpushed
wt list --full                 # + CI + AI summaries
wt remove                      # remove current worktree (deletes branch if merged; --force for dirty, -D for unmerged, --no-delete-branch to keep)
wt merge [target]              # squash + rebase + ff-merge + cleanup; target optional (defaults to repo default branch)
wt step copy-ignored           # copy gitignored files (node_modules, .direnv, target/) from main
```

If `wt switch` runs but the shell doesn't `cd`, the zsh wrapper didn't load -- check `eval "$(wt config shell init zsh)"` is in `.zshrc`.

## Manual parallel-agent fan-out

`-x` replaces wt with the named command after the worktree is ready:

```sh
wt switch -c -x claude feature-auth -- 'Fix GH #322'
wt switch -c -x claude feature-pagination -- 'Fix pagination bug'
```

Each agent gets its own working dir; concurrent edits don't collide.

## Hooks

Lifecycle events: `switch`, `start`, `commit`, `merge`, `remove`. Each has blocking `pre-*` (failure aborts) and backgrounded `post-*` (logs in `.git/wt/logs/`).

Config sources:
- User: `~/.config/worktrunk/config.toml` (in kspace: Nix-managed).
- Project: `.config/wt.toml` (committed, first-run approval required, bypass with `--yes`, skip all with `--no-hooks`).

Useful template filters: `sanitize`, `hash_port` (deterministic 10000-19999 per branch), `codename(n)`.

## kspace specifics

- **In-repo layout.** Worktrees at `kspace/.worktrees/<branch>/` (not sibling `../kspace.<branch>/`) -- agent sandbox writes need cwd containment.
- **Config is a Nix symlink.** Don't `wt config update`; edit `repos/dotfiles/modules/features/worktree.nix` and rebuild, or use `WORKTRUNK_CONFIG_PATH`.
- **Cold starts.** Fresh worktrees lack untracked files (`node_modules`, `.direnv`). Run `wt step copy-ignored` or wire it into `post-start`.
- **Multi-session staging hazard.** Each worktree has its own index, so `git add` in one worktree doesn't leak across — but when *multiple agent sessions share one worktree*, broad `git add .` will stage another session's work. Use `git commit -- <path>` with explicit pathspec.

## Debugging

- `wt -v` -- info logs + template var dumps.
- `wt -vv` -- debug logs + `.git/wt/logs/{diagnostic,trace}.log`.
