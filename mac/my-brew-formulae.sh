#!/bin/sh

# Homebrew packages installation script
#
# This file is organized with searchable comments for easy discovery.
# Each package has keywords in its comment line that you can fuzzy search.
# Examples:
#   - Search "PDF" to find sioyek
#   - Search "upscale" or "resize" to find upscayl
#   - Search "docker" or "container" to find orbstack
#   - Search "spotlight" to find raycast
#   - Search "database" or "SQL" to find dbeaver-community
#
# Use your editor's search (/, Ctrl+F) to quickly find packages by purpose
# rather than memorizing exact package names.

# ==> GUI Applications

# -> Interface & Window Management
# Tiling window manager workspace layout
brew install --cask nikitabobko/tap/aerospace
# Window borders visual focus indicator
brew install borders
# Windows-like alt-tab switcher application switcher
brew install --cask alt-tab
# Keyboard enhancement remap CapsLock hyper key modifier
brew install --cask superkey
# Mouse utility acceleration cursor speed
brew install --cask linearmouse
# Display settings monitor resolution brightness
brew install --cask betterdisplay
# Launcher productivity spotlight alternative
brew install --cask raycast
# VPN networking private network
brew install --cask tailscale
# System monitor menu bar CPU memory network
brew install --cask stats

# -> Terminal Emulators
# Terminal emulator GPU-accelerated fast
brew install --cask kitty
# Terminal emulator customizable profiles
brew install --cask iterm2
# Modern terminal AI features autocomplete
brew install --cask warp

# -> Editors and IDEs
# Code editor IDE Visual Studio Microsoft
brew install --cask visual-studio-code
# Code editor IDE lightweight fast modern
brew install --cask zed

# -> Development Tools
# Container management Docker alternative OrbStack
brew install --cask orbstack
# Git client version control GUI
brew install --cask gitkraken
# Git CLI terminal command-line version control
brew install --cask gitkraken-cli
# API client REST testing HTTP requests Postman alternative
brew install --cask insomnia
# Developer utilities JSON formatter UUID generator
brew install --cask devutils
# Database management SQL client MySQL PostgreSQL
brew install --cask dbeaver-community
# Connection manager SSH remote servers terminal
brew install --cask xpipe
# Java JDK development runtime Eclipse Temurin
brew install --cask temurin@17

# -> AI Tools
# AI assistant chatbot Claude Anthropic LLM
brew install --cask claude
# AI agent automation task runner coding assistant
brew install --cask block-goose
# Voice transcription dictation AI speech-to-text whisper
brew install --cask superwhisper

# -> Fonts
# Monospace font programming coding
brew install --cask font-iosevka-comfy
#brew install --cask font-iosevka-nerd-font
#brew install --cask font-fira-code

# ==> Applications

# -> File Management & System
# File syncing backup synchronization
brew install --cask syncthing
# Disk space visualizer analyzer storage cleanup
brew install --cask daisydisk

# -> Remote & Monitoring
# Remote desktop control access screen sharing
brew install --cask anydesk
# Time tracking productivity activity monitor
brew install --cask activitywatch

# -> Productivity & Knowledge
# Knowledge base notes Markdown graph
brew install --cask logseq
# Note-taking Markdown knowledge base
brew install --cask obsidian
# Task management TODO GTD productivity
brew install --cask todoist
# Markdown editor WYSIWYG writing
brew install --cask typora
# Flashcards spaced repetition learning memorization
brew install --cask anki
# PDF reader viewer document research
brew install --cask sioyek
# Ebook manager library converter calibre
brew install --cask calibre

# -> Communication
# Messaging chat instant messenger Telegram
brew install --cask telegram-desktop
# Messaging chat WhatsApp Facebook
brew install --cask whatsapp
# Voice chat gaming community Discord
brew install --cask discord

# -> Web Browsers
# Web browser privacy Chromium adblock
brew install --cask brave-browser

# -> Utilities
# Calculator RPN scientific math
brew install --cask speedcrunch
# Calculator natural language math
brew install --cask numi
# Screenshot screen capture annotation recording
brew install --cask cleanshot
# Image upscaler AI enhance resize upscale super-resolution
brew install --cask upscayl

# -> Security & Secrets
# Password manager vault secrets
brew install --cask bitwarden
# Encryption messaging file sharing keybase
brew install --cask keybase
# Hardware wallet crypto Trezor Bitcoin
brew install --cask trezor-suite
# Hardware wallet crypto Ledger Bitcoin Ethereum
brew install --cask ledger-live
# Bitcoin wallet cryptocurrency SPV
brew install --cask electrum
# Bitcoin wallet UTXO management privacy
brew install --cask sparrow

# -> Media & Entertainment
# Video player media player movies VLC
brew install --cask vlc
# Video player modern mpv frontend media player
brew install --cask iina
# Music streaming player Spotify
brew install --cask spotify
# Streaming movies TV shows torrents
brew install --cask stremio
# Game streaming remote gaming NVIDIA GeForce
brew install --cask moonlight

# -> Gaming
# Gaming platform games library store Steam
brew install --cask steam

# -> Image & Video Editing
# Image editor photo editing GIMP Photoshop alternative
brew install --cask gimp
# Screen recording streaming OBS broadcast
brew install --cask obs
# Keystroke visualizer screencasting presentation
brew install --cask keycastr

# -> Hardware Configuration
# Keyboard firmware flasher QMK VIA
brew install --cask qmk-toolbox
# Keyboard configurator layout remapping macros
brew install --cask via

# -> System Maintenance
# Battery charge limiter health management
brew install --cask aldente
# System maintenance cleaning optimization
brew install --cask onyx
# LaunchAgents LaunchDaemons manager startup
brew install --cask launchcontrol
# Network monitoring traceroute ping latency
brew install --cask pingplotter

# ==> CLI Tools

# -> Development
# Task runner command runner Makefile alternative automation
brew install just
# JavaScript runtime Node.js npm package manager
brew install node
# Graph visualization diagram DOT language Graphviz
brew install graphviz
# Kubernetes CLI TUI cluster management pods namespace
brew install k9s

# -> Media & Conversion
# Video converter encoding transcoding H.264 H.265
brew install ffmpeg
# Media player video audio command-line mpv
brew install mpv
# Video downloader YouTube download streaming
brew install yt-dlp
# Image manipulation convert resize crop editing ImageMagick
brew install imagemagick

# -> Network Tools
# Network bandwidth testing speed test throughput
brew install iperf
# Network bandwidth testing speed test throughput (version 3)
brew install iperf3
# Network diagnostic traceroute ping latency tool
brew install mtr
# HTTP benchmarking load testing performance stress
brew install wrk

# -> System Info
# System information fetch hardware specs neofetch
brew install fastfetch

# -> Utilities
# Terminal recording session recorder demo asciinema
brew install asciinema
# Metadata reader EXIF image info photo data
brew install exiftool
