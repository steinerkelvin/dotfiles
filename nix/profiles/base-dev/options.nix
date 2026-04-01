{ lib, ... }: {
  options.k.heavy = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Enable heavy packages and tools (neovim, language runtimes, dev tools).
      Set to false on servers and minimal environments.
    '';
  };
}
