# nixpkgs overlays applied to every host.
{ inputs, pkgs-master, ... }:
{
  nixpkgs.overlays = [
    # numtide/llm-agents.nix packages under `pkgs.llm-agents.*`, built against
    # this nixpkgs (see the flake input for why).
    inputs.llm-agents.overlays.shared-nixpkgs

    (final: prev: {
      llm-agents = prev.llm-agents // {
        # Two fixes so Quick Entry (Ctrl+Alt+Space) can register through the
        # Wayland GlobalShortcuts portal:
        #  - The app probes for the portal with a hardcoded `/usr/bin/busctl`.
        #    The upstream FHS env has no busctl, so the probe fails and the
        #    shortcut is reported as unsupported. systemd provides it.
        #  - The app identifies itself to the portal as `com.anthropic.Claude`
        #    (its Electron desktopName), and xdg-desktop-portal rejects app IDs
        #    without a matching .desktop file. Upstream names the entry
        #    claude-desktop.desktop, so install it under the app ID instead,
        #    with the matching window class, as Anthropic's own .deb does.
        claude-desktop = prev.llm-agents.claude-desktop.override {
          buildFHSEnv =
            args:
            let
              inherit (args.passthru) unwrapped;
            in
            final.buildFHSEnv (
              args
              // {
                targetPkgs = pkgs: args.targetPkgs pkgs ++ [ pkgs.systemd ];
                extraInstallCommands = ''
                  mkdir -p $out/share/applications
                  ln -s ${unwrapped}/share/icons $out/share/icons
                  ln -s ${unwrapped}/share/doc $out/share/doc
                  sed 's/^StartupWMClass=.*/StartupWMClass=com.anthropic.Claude/' \
                    ${unwrapped}/share/applications/claude-desktop.desktop \
                    > $out/share/applications/com.anthropic.Claude.desktop
                '';
              }
            );
        };
      };
    })

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
