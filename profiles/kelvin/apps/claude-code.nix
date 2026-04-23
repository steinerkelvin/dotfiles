{ ... }:

{
  programs.claude-code.enable = true;
  programs.ai-skills = {
    enableStructuralSearch = true;
    enableCodeStats = true;
  };
  programs.claude-hooks.enableCwdDirenv = true;
}
