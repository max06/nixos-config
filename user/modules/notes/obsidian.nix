{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  config = {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
