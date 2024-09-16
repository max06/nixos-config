{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  config = {
    home.packages = with pkgs; [
      vivaldi
      libsForQt5.qt5.qtwayland
    ];
  };
}
