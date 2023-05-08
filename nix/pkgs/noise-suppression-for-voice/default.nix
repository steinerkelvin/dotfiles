# JUCE Nix package

# TODO: optional dependencies

{ stdenv, lib, pkgs, ... }:

let
  repo = builtins.fetchGit {
    url = "https://github.com/werman/noise-suppression-for-voice.git";
    rev = "b31564e1a5fc5906209a596dfb737486d3b482be";
  };
in
stdenv.mkDerivation {
  pname = "noise-suppression-for-voice";
  src = repo;
  version = "1.03";

  buildInputs = with pkgs; [
    # build
    pkg-config
    cmake
    ninja

    # JUCE dependencies
    # juce_audio_devices
    alsa-lib
    libjack2 # (unless JUCE_JACK=0)
    # juce_audio_processors
    ladspa-sdk # (unless JUCE_PLUGINHOST_LADSPA=0)
    # juce_core
    curl.dev
    # juce_graphics
    freetype.dev
    # juce_gui_basics
    xorg.libX11.dev
    xorg.libXext.dev
    xorg.libXcomposite.dev
    xorg.libXcursor.dev # (unless JUCE_USE_XCURSOR=0)
    xorg.libXinerama.dev # (unless JUCE_USE_XINERAMA=0)
    xorg.libXrandr.dev # (unless JUCE_USE_XRANDR=0)
    xorg.libXrender.dev # (unless JUCE_USE_XRENDER=0)
    # juce_gui_extra
    # #libwebkit2gtk-4.0-dev (unless JUCE_WEB_BROWSER=0)
    # juce_opengl
    mesa.dev
  ];

  configurePhase = ''
    mkdir -p build-x64
    cmake -Bbuild-x64 -GNinja -DCMAKE_BUILD_TYPE=Release \
      -S. -DCMAKE_INSTALL_PREFIX=$out
  '';

  buildPhase = ''
    ninja -C build-x64
  '';

  installPhase = ''
    ninja -C build-x64 install
  '';
}
