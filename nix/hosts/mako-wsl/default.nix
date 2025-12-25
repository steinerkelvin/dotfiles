# Mako-WSL - WSL server host configuration
# Always-on server with SSH, Tailscale, and CUDA support

{ pkgs, config, lib, inputs, ... }:

let
  nixos-wsl = inputs.nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
    ../common.nix
    ./user.nix
  ];

  k.host.name = "mako-wsl";
  k.host.tags.server = true;

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  k.modules.graphical.enable = false;

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "kelvin";
    startMenuLaunchers = true;
  };

  # Enable CUDA support for WSL2 (uses Windows host driver)
  # The NVIDIA driver is provided by Windows, but we need to enable OpenGL/CUDA libraries
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Networking
  services.tailscale.enable = true;

  # SSH - configured in common.nix, additional hardening here
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  # Nix build support for dynamic binaries
  programs.nix-ld.enable = true;

  # Additional server packages
  environment.systemPackages = with pkgs; [
    htop
    neovim
    tmux
  ];
}
