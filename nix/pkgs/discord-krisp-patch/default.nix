{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  name = "discord-krisp-patch";
  src = ../../../scripts;

  installPhase = ''
    mkdir -p $out/bin

    substitute $src/discord-krisp-patch.sh $out/bin/discord-krisp-patch \
      --replace "#!/usr/bin/env nix-shell" "#!${pkgs.bash}/bin/bash" \
      --replace 'rizin_cmd="rizin"' "rizin_cmd=${pkgs.rizin}/bin/rizin" \
      --replace 'rz_find_cmd="rz-find"' "rz_find_cmd=${pkgs.rizin}/bin/rz-find"

    # cp $src/discord-krisp-patch.sh $out/bin/discord-krisp-patch

    chmod +x $out/bin/discord-krisp-patch
  '';
}
