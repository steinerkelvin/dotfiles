_: {
  flake.homeModules.file-utils = { config, lib, pkgs, ... }: {
    options.features.file-utils.yaziPreviewers.enable = lib.mkEnableOption
      "yazi preview helpers (video thumbnails, PDF, archives, JSON, search); off by default because poppler and ffmpeg are heavy closures";

    config = {
      home.packages = [
        pkgs.unzip
        # Disk usage analyzer
        pkgs.dua
        # PDF text extraction + manipulation (mutool). Self-contained;
        # poppler skipped because it drags in cairo/fontconfig/glib/X11.
        pkgs.mupdf
      ] ++ lib.optionals config.features.file-utils.yaziPreviewers.enable [
        pkgs.ffmpeg
        pkgs.poppler-utils
        pkgs.p7zip
        pkgs.jq
        pkgs.fd
        pkgs.ripgrep
        pkgs.imagemagick
      ];

      # Terminal file manager. The `y` wrapper cds the shell to where yazi exits.
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
    };
  };
}
