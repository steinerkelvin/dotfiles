# Native fzf integration (key bindings + completion), shared by zsh and
# bash. Replaces the oh-my-zsh "fzf" plugin (zsh-only).
#
# Walk with fd instead of fzf's built-in walker: fd honours .gitignore (so
# .direnv / .venv / build dirs vanish in repos that ignore them) and the
# explicit --exclude covers repos that don't.
let
  excludes = "--hidden --exclude .git --exclude .direnv";
in
_: {
  flake.homeModules.fzf = _: {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      defaultCommand = "fd --type f ${excludes}";
      fileWidgetCommand = "fd --type f ${excludes}";
      changeDirWidgetCommand = "fd --type d ${excludes}";
    };
  };
}
