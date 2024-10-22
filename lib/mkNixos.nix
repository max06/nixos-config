{
  lib,
  myLib,
  inputs,
  ...
}: let
  mkNixos = groups:
    builtins.listToAttrs (lib.concatMap (
      group: let
        members = groups.${group};
      in
        map (hostname: {
          name = hostname; # 'name' is required for listToAttrs
          value = lib.nixosSystem {
            specialArgs = {
              inherit inputs hostname; # 'hostname' needs to be inherited here
              pkgs-previous = import inputs.nixpkgs-previous {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
            modules = [
              {
                nix.settings.experimental-features = ["nix-command" "flakes"];
                nixpkgs.hostPlatform = "x86_64-linux";
                nixpkgs.config.allowUnfree = true;
              }
              (import ../overlays) # Overlay settings
              ../inventory # Inventory settings
              ../inventory/${group} # Group-specific settings
              ../inventory/${group}/${hostname} # Host-specific settings
            ];
          };
        })
        members
    ) (builtins.attrNames groups));
in
  mkNixos
