{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pinentry-qt
    kdePackages.kleopatra
  ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true; # forwarded to remote hosts, see ../../../flo/ssh
    pinentry.package = pkgs.pinentry-qt;
    maxCacheTtl = 28800; # 8h hard cap
    defaultCacheTtl = 28800; # 8h sliding
  };
}
