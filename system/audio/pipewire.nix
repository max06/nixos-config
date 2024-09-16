{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options = {
    audiosystem = mkOption {
      type = with types; nullOr (enum ["pipewire"]);
    };
  };

  config = mkIf (config.audiosystem == "pipewire") {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
  };
}
