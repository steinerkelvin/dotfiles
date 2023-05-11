#!/bin/sh


  copilot_what_the_shell () {
    TMPFILE=$(mktemp);
    trap 'rm -f $TMPFILE' EXIT;
    if /home/kelvin/.yarn/bin/github-copilot-cli what-the-shell "$@" --shellout "$TMPFILE"; then
      if [ -e "$TMPFILE" ]; then
        FIXED_CMD=$(cat "$TMPFILE");
        print -s "$FIXED_CMD";
        eval "$FIXED_CMD"
      else
        echo "Apologies! Extracting command failed"
      fi
    else
      return 1
    fi
  };
alias '??'='copilot_what_the_shell';

  copilot_git_assist () {
    TMPFILE=$(mktemp);
    trap 'rm -f $TMPFILE' EXIT;
    if /home/kelvin/.yarn/bin/github-copilot-cli git-assist "$@" --shellout "$TMPFILE"; then
      if [ -e "$TMPFILE" ]; then
        FIXED_CMD=$(cat "$TMPFILE");
        print -s "$FIXED_CMD";
        eval "$FIXED_CMD"
      else
        echo "Apologies! Extracting command failed"
      fi
    else
      return 1
    fi
  };
alias 'git?'='copilot_git_assist';

  copilot_gh_assist () {
    TMPFILE=$(mktemp);
    trap 'rm -f $TMPFILE' EXIT;
    if /home/kelvin/.yarn/bin/github-copilot-cli gh-assist "$@" --shellout "$TMPFILE"; then
      if [ -e "$TMPFILE" ]; then
        FIXED_CMD=$(cat "$TMPFILE");
        print -s "$FIXED_CMD";
        eval "$FIXED_CMD"
      else
        echo "Apologies! Extracting command failed"
      fi
    else
      return 1
    fi
  };
alias 'gh?'='copilot_gh_assist';
alias 'wts'='copilot_what_the_shell';
