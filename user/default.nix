# User accounts and home-manager wiring.
#
# Each user lives in ./<name>/default.nix and registers itself by extending
# the `hostUsers` enum. A host then lists the accounts it wants:
#   hostUsers = [ "flo" ];
# The account module creates the NixOS user; whether home-manager applies is
# decided per group (see inventory/desktop/default.nix).
{ lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./flo
  ];

  options.hostUsers = lib.mkOption {
    description = "User accounts to create on this host.";
    type = with lib.types; listOf (enum [ ]);
    default = [ ];
  };

  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
  };
}
