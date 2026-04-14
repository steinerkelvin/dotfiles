# NixOS Host Configurations

This directory contains NixOS system configurations for each machine.

## Directory Structure

```
nix/hosts/
├── common.nix      # Shared settings (SSH, locale, networking, PC audio/printing)
├── default.nix     # Exports all active hosts
├── README.md       # This file
│
├── nixia/          # Desktop PC with Nvidia GPU
│   ├── default.nix
│   ├── hardware-configuration.nix
│   └── user.nix
│
└── satsuki/        # macOS (nix-darwin)
    └── default.nix
```

## Host Configuration Files

Each active host directory contains:

- **`default.nix`** - Main system configuration (services, hardware, packages)
- **`user.nix`** - User account and home-manager setup
- **`hardware-configuration.nix`** - Auto-generated hardware config (NixOS only)

## Custom Options

Defined in `common.nix`:

- `k.host.name` - Hostname
- `k.host.domain` - Domain (default: nyala-komodo.ts.net)
- `k.host.tags.pc` - Enable PC-specific config (audio, printing)

## Adding a New Host

1. Create directory: `nix/hosts/{name}/`

2. Create `default.nix`:
   ```nix
   { inputs, ... }:
   {
     imports = [ ../common.nix ./user.nix ];

     k.host.name = "{name}";
     # k.host.tags.pc = true;      # For desktops

     system.stateVersion = "25.05";
     # ... host-specific config
   }
   ```

3. Create `user.nix`:
   ```nix
   { inputs, ... }:
   {
     config = {
       users.users.kelvin = {
         isNormalUser = true;
         extraGroups = [ "wheel" "networkmanager" ];
       };

       home-manager.extraSpecialArgs = { inherit inputs; };
       home-manager.users.kelvin = {
         imports = [
           ../../users/kelvin/hm/common.nix
           ../../users/kelvin/hm/linux.nix
           # ../../users/kelvin/hm/graphical.nix  # For desktops
         ];
         home.stateVersion = "25.05";
       };
     };
   }
   ```

4. Add to `nix/hosts/default.nix`:
   ```nix
   {name} = (import ./{name});
   ```

5. Add to `flake.nix` nixosConfigurations:
   ```nix
   {name} = mkSystem { extraModules = [ ./nix/hosts/{name} ]; };
   ```

## Helper Function

A helper function `mkKelvinUser` is available in `nix/lib/default.nix` for
creating standard user configurations. See that file for usage details.