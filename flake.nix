{
  description = "Crazy NixOS Config";

  inputs = {
    # Systemspace

    # Standard nixos ecosystem
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-pinned.url = "github:NixOS/nixpkgs?rev=4c2fcb090b1f3e5b47eaa7bd33913b574a11e0a0";
    nixpkgs-fork-netboot.url = "github:max06/nixpkgs/add-netboot-password";
    systems.url = "github:nix-systems/default";
    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    nixpkgs-pinned,
    nixpkgs-fork-netboot,
    systems,
    home-manager,
    plasma-manager,
    deploy-rs,
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
        netboot = nixpkgs-fork-netboot.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({
              config,
              modulesPath,
              ...
            }: {
              imports = [
                (modulesPath + "/installer/netboot/netboot-minimal.nix")
              ];
              config = {
                ## Some useful options for setting up a new system
                # services.getty.autologinUser = lib.mkForce "root";
                # users.users.root.openssh.authorizedKeys.keys = [ ... ];
                # console.keyMap = "de";
                # hardware.video.hidpi.enable = true;

                system.stateVersion = config.system.nixos.release;
              };
            })
          ];
        };
      };

    deploy.nodes.monster = {
      hostname = "monster";
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.monster;
      };
    };

    deploy.nodes.srv-k3s01 = {
      hostname = "192.168.27.227";
      sshUser = "root";
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.guest-proxmox;
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    packages =
      generatedPackages
      // {
        x86_64-linux =
          {
            netboot = nixpkgs-fork-netboot.legacyPackages.x86_64-linux.symlinkJoin {
              name = "netboot";
              paths = with self.nixosConfigurations.netboot.config.system.build; [
                netbootRamdisk
                kernel
                netbootIpxeScript
              ];
              preferLocalBuild = true;
            };
          }
          // generatedPackages.x86_64-linux;
      };
  };
}
