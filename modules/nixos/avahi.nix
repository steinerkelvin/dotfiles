# Reusable NixOS module: Avahi / mDNS publishing.
_: {
  flake.nixosModules.avahi = {
    services.avahi = {
      enable = true;
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
  };
}
