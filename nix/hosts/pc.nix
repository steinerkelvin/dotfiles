{ config, lib, ... }:

{
  config = lib.mkIf (config.k.host.tags.pc) {

    # Gnome Keyring
    services.gnome.gnome-keyring.enable = true;

    # Sound with PipeWire
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;
    };

    # Printer services
    services.printing.enable = true;

  };
}
