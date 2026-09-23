{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  lanzaboote = inputs.lanzaboote;
in
{
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.initrd.systemd.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoEnrollKeys = {
      enable = true;
    };
    measuredBoot = {
      enable = true;
      pcrs = [
        0
        1
        2
        3
        4
        7
      ];
    };
  };

  boot.initrd.systemd.emergencyAccess = false;

}
