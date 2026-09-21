# Reusable home-manager module: account-only credential switching for Claude
# Code and Codex. Profiles remain outside the Nix store and are created at
# runtime under $XDG_DATA_HOME/k-ai-auth with private permissions.

_: {
  flake.homeModules.k-ai-auth = { pkgs, ... }: {
    home.packages = [ pkgs.uv ];

    home.file.".local/bin/k-ai-auth" = {
      source = ../../packages/k-ai-auth.py;
      executable = true;
    };
  };
}
