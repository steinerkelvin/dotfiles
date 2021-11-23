#!/bin/sh
export EDITOR="vi"
export VISUAL="vi"
if command -v "vim" > /dev/null; then
    export VISUAL="vim"
fi
