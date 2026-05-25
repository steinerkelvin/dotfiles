_: {
  flake.homeModules.direnv = { config, lib, ... }: {
    options.programs.direnv-extras = {
      enableLayoutUv = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Install the layout_uv() direnv helper into ~/.config/direnv/direnvrc,
          enabling `layout uv` in project .envrc files for uv workspaces.
        '';
      };
      hideEnvDiff = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Set direnv's global hide_env_diff (suppress the env-diff dump printed
          on directory entry).
        '';
      };
    };

    config.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.hide_env_diff = config.programs.direnv-extras.hideEnvDiff;
      stdlib = lib.mkIf config.programs.direnv-extras.enableLayoutUv ''
        layout_uv() {
            VIRTUAL_ENV="$PWD/.venv"
            if [[ ! -d "$VIRTUAL_ENV" ]]; then
                log_status "creating venv at $VIRTUAL_ENV"
                uv venv "$VIRTUAL_ENV"
            fi
            export VIRTUAL_ENV
            export UV_PROJECT_ENVIRONMENT="$VIRTUAL_ENV"
            PATH_add "$VIRTUAL_ENV/bin"
            if [[ -f pyproject.toml ]]; then
                watch_file pyproject.toml
                watch_file uv.lock
                uv sync --quiet 2>/dev/null || log_error "uv sync failed"
            fi
        }
      '';
    };
  };
}
