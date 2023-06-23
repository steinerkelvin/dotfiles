#!/bin/sh
if command -v opam >/dev/null; then
  eval "$(opam env)"
fi
