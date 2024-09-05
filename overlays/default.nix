# This file defines overlays
{
  inputs,
  pkgs-previous,
  ...
}: {
  nixpkgs.overlays = [
    (self: super: {
      # element-desktop = pkgs-previous.element-desktop;
    })
  ];
}
