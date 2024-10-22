{
  description = "NixOS Config";

  inputs = {
    # Systemspace

    # Standard nixos ecosystem
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default-linux";

    # Older nixpkgs - currently unused
    nixpkgs-previous.url = "github:NixOS/nixpkgs?rev=18337306f0c5d7a6b6975bfa334d0d3dfd1e4c30";

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
    myLib = import ./lib {inherit inputs;};
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );

    groups = {
      desktop = [
        "monster"
      ];
    };

    nixosConfigurations = myLib.mkNixos groups;
  in {
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    inherit nixosConfigurations;
  };
}
