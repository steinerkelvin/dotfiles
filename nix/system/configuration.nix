# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      ../modules/keyd.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixia"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  services.keyd.enable = true;
  services.keyd.config.default = ''
    [ids]
    *

    [main]
    # capslock = layer(custom_caps)
    capslock = overload(custom_caps, esc)

    [custom_caps:M]
  '';

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver = {
    enable = true;

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
      sessionCommands = ''
        ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';
    };

    desktopManager.plasma5.enable = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        rofi
        i3status
        i3blocks
        i3lock
      ];
    };

    layout = "us";
    xkbVariant = "";
  };

  programs.xwayland.enable = true;
  programs.sway.enable = true;

  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kelvin = {
    isNormalUser = true;
    description = "Kelvin";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      kate
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    tree
    i3
  ];

  programs.mtr.enable = true;

  # GnuPG
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };
  security.pam.services.login.gnupg.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;

  # Enable the Mosh
  programs.mosh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    57621  # spotifyd
  ];
  networking.firewall.allowedUDPPorts = [
    5353  # spotifyd
    57621 # spotifyd
  ];

  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # SSH agent
  programs.ssh.startAgent = true;

  # Gnome Keyring

  services.gnome.gnome-keyring.enable = true;

  # services.dbus = {
  #   packages = with pkgs; [
  #     gnome3.gnome-keyring
  #     gcr
  #   ];
  # };

  # xdg.portal.extraPortals = [ pkgs.gnome3.gnome-keyring ];

  # security.wrappers.gnome-keyring-daemon = {
  #   source = "${pkgs.gnome3.gnome-keyring}/bin/gnome-keyring-daemon";
  #   capabilities = "cap_ipc_lock=ep";
  # };

  # security.pam.services.login.enableGnomeKeyring = true;
  # security.pam.services.kelvin.enableGnomeKeyring = true;
  # security.pam.services.kelvin.enableKwallet = true;

  # Home Manager

  home-manager.users.kelvin = { pkgs, config, lib, ... }: {
    home.username = "kelvin";
    home.homeDirectory = "/home/kelvin";
    home.stateVersion = "22.11";
    nixpkgs.config.allowUnfree = true;

    programs.home-manager.enable = true;

    home.sessionVariables = {
      EDITOR = "vi -e";
      VISUAL = "hx";
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.gpg.enable = true;

    services.keybase.enable = true;
    services.kbfs.enable = true;

    home.packages = with pkgs; [
      direnv
      nix-direnv
      nix-index
      dhall
      home-manager
      lorri

      lsof
      inetutils
      nmap
      pstree

      curl
      wget
      rsync
      openssh
      git

      gnupg
      git-crypt
      libsecret

      zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
      starship
      zoxide

      fzf
      silver-searcher
      ripgrep
      homesick
      stow
      shellcheck
      diff-so-fancy

      vim
      helix

      rustup

      exa
      bat

      tig

      python310Packages.ipython

      tabnine

      wakatime

      # GUI

      firefox
      microsoft-edge

      gnome.seahorse

      xorg.xmodmap
      xorg.xev
      xclip
      xdotool
      libnotify
      redshift

      pipewire
      wireplumber
      qpwgraph
      easyeffects

      networkmanagerapplet
      networkmanager_dmenu

      pulseaudio
      pavucontrol
      pulsemixer

      brightnessctl

      libinput

      i3
      i3blocks
      dmenu
      rofi
      dunst
      maim

      sway
      wofi

      wl-clipboard
      slurp
      grim

      imv
      mpv

      kitty
      vscode
      keybase-gui

      speedcrunch

      tdesktop
      discord
      calibre

      spotifyd
    ];

    # Zsh

    programs.zsh.enable = true;

    programs.starship.enable = true;

    home.file.".zshrc".text = ''
      # Load Antigen
      source ${pkgs.antigen}/share/antigen/antigen.zsh

      # Set up Antigen to use oh-my-zsh's library
      #antigen use oh-my-zsh

      # Load the plugins
      antigen bundle git
      antigen bundle zsh-users/zsh-autosuggestions
      antigen bundle zsh-users/zsh-syntax-highlighting
      antigen bundle fzf
      antigen bundle git
      antigen bundle cargo
      antigen bundle pip
      antigen bundle yarn
      antigen bundle command-not-found

      # Load the theme
      #antigen theme robbyrussell
      if command -v "starship" >/dev/null; then
        eval "$(starship init zsh)"
      else
        export AGKOZAK_LEFT_PROMPT_ONLY=1
        export AGKOZAK_BLANK_LINES=1
        antigen theme agkozak/agkozak-zsh-prompt
      fi

      # Apply the settings
      antigen apply

      # Setup Zoxide
      if command -v "zoxide" >/dev/null; then
        eval "$(zoxide init zsh)"
      fi

      # Vim mode
      bindkey -v
    '';

    # Vim

    programs.neovim = {
      enable = true;
      coc = {
        enable = true;
      };
      plugins = with pkgs.vimPlugins; [
        vim-nix
        yankring
        zoxide-vim
        which-key-nvim
        vim-easymotion
        vim-multiple-cursors
        copilot-vim
        coc-tabnine
        vim-monokai-pro
        # vim-wakatime
      ];
      extraConfig = ''
        " space key as Leader
        nnoremap <Space> <Nop>
        let g:mapleader = "\<Space>"

        " non-yank delete
        nnoremap <leader>d "_d
        xnoremap <leader>d "_d

        " which-key config
        "nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

        " line numbers
        set number

        " indentation config
        set expandtab
        set tabstop=4
        set shiftwidth=4
      '';
    };

    services.spotifyd = {
      enable = true;
      settings = {
        global = {
          device_name = "nixia";
          zeroconf_port = 57621;
          username = "kelvinsteiner";
          # password = "<pass>";   # TODO: secrets
        };
      };
    };

    home.file.".Xmodmap".text = ''
      keycode 66 = Hyper_L

      clear lock
      clear mod3
      clear mod4

      add mod3 = Hyper_L
      add mod4 = Super_L Super_R
    '';

    programs.i3status = {
      enable = true;
      package = pkgs.i3blocks;
    };

    xsession = {
      enable = true;

      profileExtra = ''
        ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';

      initExtra = ''
        ${config.home.homeDirectory}/.nix-profile/bin/xmodmap ${config.home.homeDirectory}/.Xmodmap
      '';

      windowManager.i3 = {
        enable = true;
        config =
          let
            mod = "Mod3";
            cfg = config.xsession.windowManager.i3.config;
          in {
          modifier = "${mod}";
          terminal = "kitty";
          # TODO: fix i3blocks
          bars = [
            {
              command = "${pkgs.i3blocks}/bin/i3blocks -c \${HOME}/.i3blocks.conf";
            }
          ];
          keybindings =
            {
              # open terminal
              "${mod}+Return" = "exec kitty";
              # fallback if `mod` is misconfigured
              "Mod1+Return" = "exec xterm";

              # commands menu
              "${mod}+d"       = "exec rofi -show run";
              "${mod}+Shift+d" = "exec rofi -show drun";
              # fallback commands menu
              "Mod1+d" = "exec ${cfg.menu}";

              # close window
              "${mod}+Shift+q" = "kill";

              # vim-like focus window
              "${mod}+h" = "focus left";
              "${mod}+j" = "focus down";
              "${mod}+k" = "focus up";
              "${mod}+l" = "focus right";

              # focus parent
              "${mod}+a"            = "focus parent";

              # vim-like move window
              "${mod}+Shift+h"      = "move left";
              "${mod}+Shift+j"      = "move down";
              "${mod}+Shift+k"      = "move up";
              "${mod}+Shift+l"      = "move right";

              # split in horizontal orientation
              "${mod}+b"             = "split h";
              # split in vertical orientation
              "${mod}+v"            = "split v";

              # fullscreen
              "${mod}+f"            = "fullscreen toggle";

              # set layout
              "${mod}+s"            = "layout stacking";
              "${mod}+w"            = "layout tabbed";
              "${mod}+e"            = "layout toggle split";

              # floating mode
              "${mod}+Shift+space"  = "floating toggle";

              # resizing
              "${mod}+r"             = "mode resize";

              # scratchpad
              "${mod}+Shift+minus"   = "move scratchpad";
              "${mod}+minus"         = "scratchpad show";

              # worspaces

              "${mod}+space"        = "focus mode_toggle";
              "${mod}+1"            = "workspace 1";
              "${mod}+2"            = "workspace 2";
              "${mod}+3"            = "workspace 3";
              "${mod}+4"            = "workspace 4";
              "${mod}+5"            = "workspace 5";
              "${mod}+6"            = "workspace 6";
              "${mod}+7"            = "workspace 7";
              "${mod}+8"            = "workspace 8";
              "${mod}+9"            = "workspace 9";
              "${mod}+0"            = "workspace 10";

              "${mod}+Shift+1"      = "move container to workspace 1";
              "${mod}+Shift+2"      = "move container to workspace 2";
              "${mod}+Shift+3"      = "move container to workspace 3";
              "${mod}+Shift+4"      = "move container to workspace 4";
              "${mod}+Shift+5"      = "move container to workspace 5";
              "${mod}+Shift+6"      = "move container to workspace 6";
              "${mod}+Shift+7"      = "move container to workspace 7";
              "${mod}+Shift+8"      = "move container to workspace 8";
              "${mod}+Shift+9"      = "move container to workspace 9";
              "${mod}+Shift+0"      = "move container to workspace 10";

              "${mod}+Ctrl+Shift+h" = "move workspace to output left";
              "${mod}+Ctrl+Shift+j" = "move workspace to output down";
              "${mod}+Ctrl+Shift+k" = "move workspace to output up";
              "${mod}+Ctrl+Shift+l" = "move workspace to output right";
              "${mod}+Ctrl+Shift+Left"   = "move workspace to output left";
              "${mod}+Ctrl+Shift+Down"   = "move workspace to output down";
              "${mod}+Ctrl+Shift+Up"     = "move workspace to output up";
              "${mod}+Ctrl+Shift+Right"  = "move workspace to output right";

              # i3 management

              "${mod}+Shift+c"       = "reload";
              "${mod}+Shift+e"       = ''exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"'';

              # screenshot

              "${mod}+p"             = "exec maim -s | xclip -sel clip -t image/png";
              "${mod}+Ctrl+p"        = "exec maim -s > ./screenshots/$(date -Iseconds).png";
              "${mod}+Shift+p"       = "exec maim | xclip -sel clip -t image/png";
              "${mod}+Shift+Ctrl+p"  = "exec maim > ./screenshots/$(date -Iseconds).png";

              # volume control
              "${mod}+F12"  = "exec pactl set-sink-volume $(pacmd list-sinks | awk '/* index:/{print $3}') +5%";
              "${mod}+F11"  = "exec pactl set-sink-volume $(pacmd list-sinks | awk '/* index:/{print $3}') -5%";

              # bringhtness control
              "${mod}+F9"            = "exec brightness s 10%-";
              "${mod}+F10"           = "exec brightness s +10%";

               # TODO: port rest of custom keybindings
            };
          };
       };
    };

    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty";
        startup = [
          { command = "firefox"; }
        ];
        keybindings = let
            modifier = config.wayland.windowManager.sway.config.modifier;
          in lib.mkOptionDefault {
            "${modifier}+d"       = "exec  wofi --show run";
            "${modifier}+Shift+d" = "exec  wofi --show drun";
            ## Screenshot
            "${modifier}+p"             = "exec  grim -g \"$(slurp)\" - | wl-copy";
            "${modifier}+Ctrl+p"        = "exec  grim -g \"$(slurp)\" \"./screenshots/$(date -Iseconds).png\"";
            "${modifier}+Shift+p"       = "exec  grim - | wl-copy";
            "${modifier}+Shift+Ctrl+p"  = "exec  grim \"./screenshots/$(date -Iseconds).png\"";
          };
        };
      extraConfig = ''
        input * {
          xkb_layout "us"
          xkb_options "compose:rctrl"
        }
      '';
    };

    # services.mako.enable = true;
    # services.clipman.enable = true;

    programs.waybar.enable = true;

  };

}
