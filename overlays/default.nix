# This file defines overlays
{
  inputs,
  pkgs,
  pkgs-previous,
  ...
}: {
  nixpkgs.overlays = [
    (self: super: {
      # element-desktop = pkgs-previous.element-desktop;
    })

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

    # (final: prev: {
    #   vscode = pkgs-previous.vscode;
    # })
  ];
}
