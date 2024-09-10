{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options = {
    audiosystem = mkOption {
      type = with types; nullOr (enum ["pulseaudio"]);
    };
  };

  config = mkIf (config.audiosystem == "pulseaudio") {
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };

    hardware.pulseaudio.extraConfig = "load-module module-switch-on-connect";
  };
}
