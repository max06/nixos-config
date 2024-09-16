{...}: {
  imports = [
    ../../system/bluetooth
    ../../system/audio
  ];

  config = {
    audiosystem = "pipewire";
    foo.users = ["flo"];
  };
}
