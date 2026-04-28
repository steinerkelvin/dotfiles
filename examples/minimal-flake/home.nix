{ ... }:

{
  home.username = "example";
  home.homeDirectory = "/Users/example";
  home.stateVersion = "25.11";

  # Enable the imported feature. Mirror this block for every
  # `homeModules.<x>` you import in flake.nix.
  features.dep-opsec.enable = true;

  # If you imported `homeModules.base-dev` instead, you don't need any
  # explicit toggle -- base-dev composes its sibling features directly.
}
