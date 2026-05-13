_: {
  flake.homeModules.file-utils = { pkgs, ... }: {
    home.packages = [
      pkgs.unzip
      # Disk usage analyzer
      pkgs.dua
      # PDF text extraction + manipulation (mutool). Self-contained;
      # poppler skipped because it drags in cairo/fontconfig/glib/X11.
      pkgs.mupdf
    ];
  };
}
