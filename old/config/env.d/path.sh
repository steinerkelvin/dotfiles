#!/bin/sh

# TODO: function

if [ -d "/home/kelvin/.gem/ruby/2.7.0/bin" ] ; then
    PATH="/home/kelvin/.gem/ruby/2.7.0/bin:$PATH"
fi

if [ -d "$HOME/.deno/bin" ] ; then
    PATH="$HOME/.deno/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ] ; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -d "$HOME/.yarn/bin" ] ; then
    PATH="$HOME/.yarn/bin:$PATH"
fi

if [ -d "$HOME/Library/Python/3.9/bin" ] ; then
    PATH="$HOME/Library/Python/3.9/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/opt/bin" ] ; then
    PATH="$HOME/opt/bin:$PATH"
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

