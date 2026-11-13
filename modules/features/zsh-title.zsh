# Terminal title: the working directory at all times, plus the command while
# one runs ("~/src/proj — nvim README.md"). The stock behaviour (kitty's shell
# integration, oh-my-zsh) swaps the directory out for the command, so window
# titles -- and anything that reads them, like time trackers -- lose the
# project whenever a program is in the foreground. Both are turned off
# (kitty: `no-title`; oh-my-zsh: DISABLE_AUTO_TITLE) in favour of this.
# Programs that set their own title still override it while they run.
_title_set() {
  [[ -t 1 && $TERM != (dumb|linux) ]] || return 0
  local host=${SSH_CONNECTION:+${HOST%%.*}: }
  print -rn -- $'\e]2;'"${host}${(%):-%~}${1:+ — ${(V)1[1,80]}}"$'\a'
}
_title_precmd() { _title_set }
_title_preexec() { _title_set "$1" }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _title_precmd
add-zsh-hook preexec _title_preexec
