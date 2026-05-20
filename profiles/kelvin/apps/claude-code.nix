{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  programs.claude-code.enable = true;
  programs.ai-skills = {
    enableStructuralSearch = true;
    enableCodeStats = true;
    enableDiagramTools = true;
  };
  programs.claude-hooks.enableCwdDirenv = true;

  home.file.".claude/statusline-command.sh" = {
    source = ./statusline-command.sh;
    executable = true;
  };

  # User-level ~/.claude/settings.json. Claude Code's live runtime state
  # (sessions, onboarding, model usage) lives in ~/.claude.json, so HM
  # can own this file without fighting the app's internal writes.
  programs.claude-code.settings = {
    theme = "dark";
    verbose = false;
    editorMode = "vim";
    autoUpdaterStatus = "enabled";
    preferredNotifChannel = "kitty";
    effortLevel = "high";
    useAutoModeDuringPlan = true;
    prefersReducedMotion = true;

    # Deliberate permission-prompt bypasses. Accepting the blast radius
    # in exchange for not breaking flow on every auto/dangerous action.
    skipDangerousModePermissionPrompt = true;
    skipAutoPermissionPrompt = true;

    ignorePatterns = [
      "node_modules"
      ".git"
      "dist"
      "build"
      "target"
      "coverage"
    ];

    permissions = {
      defaultMode = "auto";
      allow = [
        "mcp__ide__getDiagnostics"
        "WebSearch"
        "Bash(find:*)"
        "Bash(ls:*)"
        "Bash(tree:*)"
        "Bash(mkdir:*)"
        "Bash(git status)"
        "Bash(git diff)"
        "Bash(git log)"
        "Bash(git ls-files)"
        "Bash(git rev-parse)"
        "Bash(dig +short:*)"
        "WebFetch(domain:docs.anthropic.com)"
        "WebFetch(domain:forum.obsidian.md)"
      ];
    };

    statusLine = {
      type = "command";
      command = "bash ${home}/.claude/statusline-command.sh";
    };

    enabledPlugins = {
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "pyright-lsp@claude-plugins-official" = true;
      "telegram@claude-plugins-official" = true;
      "codex@openai-codex" = true;
    };

    extraKnownMarketplaces."openai-codex".source = {
      source = "github";
      repo = "openai/codex-plugin-cc";
    };

    sandbox = {
      filesystem.allowWrite = [ "${home}/.codex" ];
      # Each codex-spawning companion subcommand must be excluded from Claude's
      # sandbox: on macOS Codex applies its own seatbelt per shell command, which
      # fails when nested inside Claude's seatbelt (shell dies -> falls back to a
      # broken qmd MCP and hangs). Keep in sync with the runtime's subcommands
      # (`just codex-check` in kspace verifies this). `rescue` was renamed to
      # `task`; `adversarial-review` is a distinct subcommand.
      excludedCommands = [
        ''node "${home}/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs" review *''
        ''node "${home}/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs" adversarial-review *''
        ''node "${home}/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs" task *''
      ];
    };
  };
}
