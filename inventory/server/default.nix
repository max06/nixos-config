# Server group: headless hosts, administered over SSH and deployed with
# `nixos-rebuild --target-host`.
{ pkgs, ... }:
{
  hostUsers = [ "flo" ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = import ../../user/flo/keys.nix;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 16;
      efi.canTouchEfiVariables = true;
    };
  };
}
