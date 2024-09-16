{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    ./pipewire.nix
    ./pulseaudio.nix
  ];

  options = {
    audiosystem = mkOption {
      description = "Audio system to use";
      type = with types; nullOr (enum []);
      default = null;
    };
  };
}
