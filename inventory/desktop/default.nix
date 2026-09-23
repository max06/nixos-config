# Desktop group: KDE Plasma workstation defaults.
{ pkgs, ... }:
{
  imports = [
    ../../system/bluetooth
    ../../system/audio
  ];

  hostUsers = [ "flo" ];
  home-manager.users.flo = import ../../user/flo/home/desktop.nix;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam and other 32-bit games
  };

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    corefonts
    vista-fonts
  ];

  services.flatpak.enable = true;
  programs.steam.enable = true;
}
