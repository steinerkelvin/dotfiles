{ lib, config, pkgs, ... }:

let
  machineKind = config.k.host.kind;
  isPC = lib.elem machineKind [ "pc" ];
in {

  imports = [
    ../modules/services/ddns.nix
  ];

  options.k = let
    types = lib.types;
    mkOption = lib.mkOption;
  in {
    host.name = mkOption { type = types.str; };
    host.domain = mkOption { type = types.str; };
    host.kind = mkOption {
      type = types.enum [ "bare" "pc" ];
      default = "bare";
    };
  };

  config = lib.mkMerge [

    {
      k.host.domain = "h.steinerkelvin.dev";

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;

      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;

      environment.systemPackages = with pkgs; [
        # Editors
        vim
        neovim
        helix
        # Nix tools
        nix-index
        nixos-option
        # System tools
        lsof
        tree
        pstree
        # Network tools
        inetutils
        dig
        nmap
        # Connectivity
        curl
        wget
        rsync
        openssh
        git
      ];

      programs.mtr.enable = true;

      # Hostname
      networking.hostName = config.k.host.name;
      networking.domain = config.k.host.domain;

      # Enable networking
      networking.networkmanager.enable = true;

      # SSH
      services.openssh.enable = true;
      services.openssh.settings.X11Forwarding = true;
      # SSH agent
      programs.ssh.startAgent = true;
      # Mosh
      programs.mosh.enable = true;

      # GnuPG / GPG / PGP
      programs.gnupg.agent = {
        enable = true;
        # enableSSHSupport = true;
      };
      security.pam.services.login.gnupg.enable = true;

      # Local network name resolution
      services.resolved = lib.mkIf (isPC) {
        enable = true;
        domains = [ "m.steinerkelvin.dev" ];
        fallbackDns =
          [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      };

      # Avahi / mDNS
      services.avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          hinfo = true;
          userServices = true;
          workstation = true;
        };
      };

      # Time Zone
      time.timeZone = "America/Sao_Paulo";

      # Internationalisation
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

    }

    (lib.mkIf isPC {

      # Gnome Keyring
      services.gnome.gnome-keyring.enable = true;

      # Sound with PipeWire
      sound.enable = true;
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        #jack.enable = true;
      };

      services.xserver.libinput.enable = true;

      # Printer services
      services.printing.enable = true;

    })
    
    {
      programs.adb.enable = true;
    }

  ];

}
