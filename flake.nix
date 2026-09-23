{
  description = "NixOS configuration for Flo's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Fallback channels. Packages on unstable occasionally break; these let a
    # single package be pulled from elsewhere through the specialArgs
    # pkgs-stable / pkgs-master / pkgs-staging / pkgs-pinned or an overlay:
    #   stable  - not broken yet
    #   master  - already fixed, not yet propagated to unstable
    #   staging - fixed in a mass-rebuild branch
    #   pinned  - a specific revision (e.g. while a PR is unmerged)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-staging.url = "github:NixOS/nixpkgs/staging";
    nixpkgs-pinned.url = "github:NixOS/nixpkgs?rev=615fed819cb087395330c7513f3ed4acb49d06a9";

    systems.url = "github:nix-systems/default";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Declarative partitioning (used when installing new hosts)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets (sops with gpg + age recipients)
    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    # Declarative Proxmox VMs (virtualisation.proxmox.*)
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      myLib = import ./lib { inherit inputs; };

      forEachSystem =
        f:
        lib.genAttrs (import systems) (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );

      # Hosts grouped by role. Every host gets inventory/default.nix, then
      # inventory/<group>/default.nix, then inventory/<group>/<host>.nix.
      groups = {
        desktop = [ "monster" ];
        server = [
          "rancher"
          "pw"
        ];
      };

      # Standalone home-manager profiles for devcontainers (see install.sh).
      # Container images use a small set of usernames; one configuration is
      # generated per name so the home-manager CLI can pick it by $USER.
      containerUsers = [
        "vscode"
        "node"
        "root"
        "codespace"
        "ubuntu"
        "coder"
      ];

      mkContainerHome =
        {
          username,
          homeDirectory,
          pkgs,
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./user/flo/home/container.nix
            { home = { inherit username homeDirectory; }; }
          ];
        };
    in
    {
      formatter = forEachSystem (pkgs: pkgs.nixfmt);

      nixosConfigurations = myLib.mkNixos groups;

      homeConfigurations =
        lib.genAttrs containerUsers (
          username:
          mkContainerHome {
            inherit username;
            homeDirectory = if username == "root" then "/root" else "/home/${username}";
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          }
        )
        // {
          # Fallback for any other username. Needs `--impure`: user, home and
          # system are read from the environment at evaluation time.
          container = mkContainerHome {
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
            pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
          };
        };

      # `nix flake check` evaluates every host's toplevel. All hosts are
      # x86_64-linux, so the check is only exposed for that system.
      checks.x86_64-linux = lib.mapAttrs' (
        name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel
      ) self.nixosConfigurations;

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            nixd
            sops
            age
            ssh-to-age
          ];
        };
      });
    };
}
