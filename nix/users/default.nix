{
  kelvin = {
    hm = import ./kelvin/hm;
    hosts = {
      nixia = import ./kelvin/nixos/hosts/nixia.nix;
      kazuma = import ./kelvin/nixos/hosts/kazuma.nix;
    }; 
  };
}
