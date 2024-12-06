{
  description = "NixOS Config";

  inputs = {
    # Systemspace

    # Standard nixos ecosystem
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    # Partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    disko,
    nixos-generators,
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

    generatedNixosConfigurations = myLib.mkNixos groups;
    generatedPackages =
      forEachSystem (pkgs:
        import ./packages/default.nix {inherit pkgs;});
  in {
    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations =
      generatedNixosConfigurations
      // {
        guest-proxmox = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./profiles/hardware/virtual
            ./profiles/hardware/virtual/proxmox
            # ./configuration.nix
            # ./hardware-configuration.nix
          ];
        };
      };


    packages =
      generatedPackages
      // {
        x86_64-linux =
          {
          }
          // generatedPackages.x86_64-linux;
      };
  };
}
