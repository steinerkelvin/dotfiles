{ ... }:

{
  imports = [
    ../base-dev
    ./claude-code.nix
  ];

  programs.claude-code = {
    enable = true;
    enableStructuralSearch = true;
    enableCodeStats = true;
  };
}
