# nixpkgs overlays applied to every host.
{ pkgs-master, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # Flo maintains vivaldi in nixpkgs; take it from master so new releases
      # are available before they propagate to unstable. Force Wayland.
      vivaldi = pkgs-master.vivaldi.override {
        commandLineArgs = ''
          --enable-features=UseOzonePlatform
          --ozone-platform=wayland
          --ozone-platform-hint=auto
          --enable-features=WaylandWindowDecorations
        '';
      };
    })
  ];
}
