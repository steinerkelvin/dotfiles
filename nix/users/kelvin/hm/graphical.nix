{ lib, config, pkgs, ... }:

# TODO: split basic graphical / etc

{

  imports = [
    ./i3.nix
    ./polybar.nix
    ./sway.nix
  ];

  # Enable user fonts
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # X11 / Xorg
    xorg.xmodmap
    xorg.xev
    xclip
    xdotool
    libnotify
    redshift

    # Terminal
    kitty
    viu

    # GUI Apps
    ## Browser
    firefox
    brave
    ## Note-taking
    logseq
    ## File Manager
    dolphin
    ## Communication
    tdesktop
    discord
    calibre
    qbittorrent
    ## Music
    spotify
    ## Audio
    gnome.gnome-sound-recorder
    ## Screencast
    peek
    ## Image-editing
    gimp
    krita
    ## Misc
    keybase-gui
    ## Tools
    speedcrunch
    ## Dev
    vscode
    tabnine
    wakatime

    ## AppImage
    appimage-run

    # Audio
    ## Pipewire
    pipewire
    wireplumber
    qpwgraph
    easyeffects
    ## Pulseaudio
    pulseaudio
    pavucontrol
    pulsemixer

    # Screen
    ## Brightness
    ddcutil
    ddcui

    # Network
    networkmanagerapplet
    networkmanager_dmenu

    # Credentials
    gnome.seahorse

    # Input tools
    libinput

    # Tiling native apps
    imv
    mpv
    zathura

    # Fonts
    pkgs.liberation_ttf
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-emoji
    pkgs.dejavu_fonts
    pkgs.roboto
    pkgs.ubuntu_font_family
    ## Dev
    pkgs.inconsolata
    pkgs.iosevka
    (pkgs.nerdfonts.override { fonts = [ "Inconsolata" "Iosevka" "FiraCode" "DroidSansMono" "Noto" ]; })
    ## Content
    xkcd-font
  ];

  xsession = {
    enable = true;

    profileExtra = ''
      ${
        lib.getBin pkgs.dbus
      }/bin/dbus-update-activation-environment --systemd --all
    '';

    initExtra = ''
      ${config.home.homeDirectory}/.nix-profile/bin/xmodmap ${config.home.homeDirectory}/.Xmodmap
    '';
  };

  # Xmodmap: Capslock as Hyper key
  home.file.".Xmodmap".text = ''
    keycode 66 = Hyper_L

    clear lock
    clear mod3
    clear mod4

    add mod3 = Hyper_L
    add mod4 = Super_L Super_R
  '';

  # Autostart Terminal with ssh-add
  home.file."config/kitty/ssh-add-session.kitty".text = ''
    launch zsh -c 'ssh-add; $SHELL'
  '';

  # XDG User Dirs
  home.file = {
    ".config/user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/desktop"
      XDG_DOWNLOAD_DIR="$HOME/downloads"
      XDG_TEMPLATES_DIR="$HOME/templates"
      XDG_PUBLICSHARE_DIR="$HOME/public"
      XDG_DOCUMENTS_DIR="$HOME/documents"
      XDG_MUSIC_DIR="$HOME/music"
      XDG_PICTURES_DIR="$HOME/pictures"
      XDG_VIDEOS_DIR="$HOME/videos"
    '';
  };

}
