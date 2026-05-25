# Reusable NixOS module: pull selected fast-moving packages from
# nixpkgs-unstable while the system stays on stable. Mirrors the home-manager
# `unstable` overlay (modules/overlays.nix) so dotfiles homeModules consumed via
# home-manager `useGlobalPkgs` (which take the system pkgs) can resolve
# unstable-sourced packages.
#   - worktrunk: git worktree manager (dotfiles `worktree` homeModule); not in
#     stable 25.11 yet.
#   - dgop: Go system-monitoring backend for DankMaterialShell; DMS's homeModule
#     defaults dgop.package to pkgs.dgop, which is unstable-only.
#   - age-plugin-tpm: TPM-backed age identity for agenix boot decryption; stable
#     25.11 predates the v1.0.1 multi-recipient fix + p256tag recipient scheme.
{ inputs, ... }:
{
  flake.nixosModules.unstable-packages = {
    nixpkgs.overlays = [
      (_final: prev: {
        inherit
          (inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system})
          worktrunk
          dgop
          age-plugin-tpm
          ;
      })
    ];
  };
}
