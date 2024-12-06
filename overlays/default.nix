# This file defines overlays
{
  inputs,
  pkgs,
  pkgs-pinned,
  ...
}: {
  nixpkgs.overlays = [
    # (self: super: {
    #   libreoffice-qt6-fresh = pkgs-pinned.libreoffice-qt6-fresh;
    # })

    (final: prev: {
      vivaldi =
        (prev.vivaldi.overrideAttrs (oldAttrs: {
          dontWrapQtApps = false;
          dontPatchELF = true;
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.kdePackages.wrapQtAppsHook];
        }))
        .override {
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
