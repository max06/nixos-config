{ pkgs, ... }:
{
  # TODO: autostart as a user service (no home-manager module exists yet).
  home.packages = [ pkgs.synology-drive-client ];
}
