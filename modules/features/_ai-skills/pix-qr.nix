{ config, lib, ... }: {
  # Regional opt-in: pix-qr is Brazil-specific (BR Code / EMV-MPM payment QR).
  # The gate is exposed as a generic regional flag so future BR-only skills can
  # share it without re-declaring. Off by default in public dotfiles; consumer
  # hosts (e.g. kspace) flip it on.
  options.features.regional.brazil.enable = lib.mkEnableOption ''
    Brazil-regional opt-in features (currently: pix-qr Claude Code skill).
    Off by default in public dotfiles; opt-in per-host.
  '';

  config = lib.mkIf (config.programs.claude-code.enable && config.features.regional.brazil.enable) {
    programs.claude-code.skills.pix-qr = ./pix-qr;
  };
}
