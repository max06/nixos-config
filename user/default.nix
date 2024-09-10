{
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./flo
    ./foo
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
    # home-manager.users.flo = import ../home.nix;

    home-manager.users = listToAttrs (map (
        user:
        # nameValuePair "${user}" (import ../home.nix)
          nameValuePair "${user}" (import ./${user})
      )
      config.foo.users);
  };
}
