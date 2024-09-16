{
  description = "NixOS Config";

  inputs = {
    # Systemspace

    # Standard nixos ecosystem
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default-linux";

    # Older nixpkgs - currently unused
    nixpkgs-previous.url = "github:NixOS/nixpkgs?rev=8987be1fef03440514ebf3b0b60e0c44fc13eb6c";

    # Secureboot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Userspace
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-previous,
    systems,
    home-manager,
    plasma-manager,
    ...
  }: let
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      groups = {
        desktop = [
          "monster"
        ];
      };
    in
      builtins.foldl' (
        acc: group:
          acc
          // lib.genAttrs groups.${group} (
            hostname:
              lib.nixosSystem {
                specialArgs = {
                  inherit inputs hostname;
                  pkgs-previous = import nixpkgs-previous {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
                modules = [
                  {
                    nix.settings.experimental-features = ["nix-command" "flakes"];
                    nixpkgs.hostPlatform = system;
                    nixpkgs.config.allowUnfree = true;
                  }
                  (import ./overlays)
                  ./inventory
                  ./inventory/${group}
                  ./inventory/${group}/${hostname}
                ];
              }
          )
      ) {} (builtins.attrNames groups);
  };
}
