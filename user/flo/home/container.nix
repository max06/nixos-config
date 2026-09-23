# flo's home inside a devcontainer: the core layer only.
# home.username / home.homeDirectory are supplied by flake.nix.
{ ... }:
{
  imports = [ ./core.nix ];

  isDevContainer = true;
}
