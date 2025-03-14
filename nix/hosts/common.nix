{ lib, config, pkgs, ... }:

# TODO: adapt to Linux & Darwin simultaneously

let isPC = config.k.host.tags.pc;
in {

  imports = [ ./pc.nix ./server.nix ];

  options.k =
    let
      types = lib.types;
      mkOption = lib.mkOption;
    in
    {
      host.name = mkOption { type = types.str; };
      host.domain = mkOption { type = types.str; };
      host.tags.pc = lib.mkEnableOption "host is PC";
      host.tags.server = lib.mkEnableOption "host is server";
    };

  config = {
    # lib.mkMerge [

    k.host.domain = "h.steinerkelvin.dev";

    # Nix
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # TODO: auto generate / https://github.com/NixOS/nix/issues/3023#issuecomment-781131502
      trusted-public-keys = [
        "nixia:XXUjJsyALoE9qJQGbajFwro4kLV2lK2e6ojhFR2BN90=" # nixia-pub-key.pem
      ];
    };

    # Shell
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    # Programs

    environment.systemPackages = with pkgs; [
      # Editors
      vim
      neovim
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
      pkgs.ethtool
      # Connectivity
      curl
      wget
      rsync
      openssh
      git
    ];

    programs.mtr.enable = true;

    # SSH
    services.openssh.enable = true;
    services.openssh.settings.X11Forwarding = true;
    services.openssh.settings.PermitRootLogin = "no";
    services.openssh.ports = [ 2200 ];

    # SSH agent
    programs.ssh.startAgent = true;
    # Mosh
    programs.mosh.enable = true;

    # GnuPG / GPG / PGP
    programs.gnupg.agent = {
      enable = true;
      # enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
    security.pam.services.login.gnupg.enable = true;

    # Networking
    networking.networkmanager.enable = true;

    ## Hostname
    networking.hostName = config.k.host.name;
    networking.domain = config.k.host.domain;

    ## Local network name resolution
    services.resolved = lib.mkIf (isPC) {
      enable = true;
      domains = [ "h.steinerkelvin.dev" ];
      fallbackDns =
        [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
    };

    # Avahi / mDNS
    # TODO: `lan` tag?
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
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

    # Internationalization
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LANG = "en_US.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_NUMERIC = "en_DK.UTF-8";
      LC_TIME = "en_DK.UTF-8";

      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      # LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      # LC_TIME = "pt_BR.UTF-8";
    };

  };
}
