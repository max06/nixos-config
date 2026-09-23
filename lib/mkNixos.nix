# Turns { <group> = [ <hostname> ... ]; } into nixosConfigurations.
#
# Every host is composed from, in order:
#   1. the inline base module below (platform, unfree, flakes)
#   2. shared third-party modules (overlays, disko, sops-nix, proxmox-nixos)
#   3. inventory/default.nix            - applies to every host
#   4. inventory/<group>/default.nix    - group defaults
#   5. inventory/<group>/<hostname>.nix - the host itself
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  system = "x86_64-linux";

  # Alternative nixpkgs evaluations, exposed as specialArgs so any module can
  # take a single package from another channel (see flake.nix inputs).
  importNixpkgs =
    input:
    import input {
      inherit system;
      config.allowUnfree = true;
    };

  mkHost =
    group: hostname:
    lib.nameValuePair hostname (
      lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs-stable = importNixpkgs inputs.nixpkgs-stable;
          pkgs-master = importNixpkgs inputs.nixpkgs-master;
          pkgs-staging = importNixpkgs inputs.nixpkgs-staging;
          pkgs-pinned = importNixpkgs inputs.nixpkgs-pinned;
        };
        modules = [
          {
            networking.hostName = hostname;
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }
          ../overlays
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.proxmox-nixos.nixosModules.declarative-vms
          ../inventory
          ../inventory/${group}
          ../inventory/${group}/${hostname}.nix
        ];
      }
    );

  mkGroup = group: hostnames: map (mkHost group) hostnames;
in
groups: lib.listToAttrs (lib.concatLists (lib.mapAttrsToList mkGroup groups))
