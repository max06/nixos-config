{
  config,
  pkgs,
  ...
}: {
  config = {
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };

    hardware.pulseaudio.extraConfig = "load-module module-switch-on-connect";
  };
}
