# Reusable NixOS module: hardened OpenSSH (key-only, no root password login).
#
# Stays on the upstream default port (22). A host that wants a custom port sets
# the stock option:  services.openssh.ports = [ 2200 ];
_: {
  flake.nixosModules.ssh = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
