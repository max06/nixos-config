{
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./flo
  ];

  options = {
    foo.users = mkOption {
      description = "Users for a system";
      type = with types; listOf (enum []);
      default = [];
    };
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [inputs.plasma-manager.homeManagerModules.plasma-manager];
  };
}
