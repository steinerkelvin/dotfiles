{ ... }:

{
  imports = [
    ../base-dev
    ./ai-skills.nix
  ];

  programs.claude-code = {
    enable = true;
    enableStructuralSearch = true;
    enableCodeStats = true;
  };
}
