{ inputs, ... }:
{
  mkNixos = import ./mkNixos.nix { inherit inputs; };
}
