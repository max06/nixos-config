{...}: {
  imports = [
    ../../system/bluetooth
    ../../system/audio/pulseaudio.nix
  ];

  config = {
    audiosystem = "pulseaudio";
  };
}
