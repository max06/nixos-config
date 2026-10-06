# nixpkgs overlays applied to every host.
{ inputs, pkgs-master, ... }:
{
  nixpkgs.overlays = [
    # numtide/llm-agents.nix packages under `pkgs.llm-agents.*`, built against
    # this nixpkgs (see the flake input for why).
    inputs.llm-agents.overlays.shared-nixpkgs

    (final: prev: {
      # LM Studio's ROCm engine runs inside the AppImage FHS env and loads the
      # ROCm runtime from its own vendor pack
      # (~/.lmstudio/extensions/backends/vendor/linux-llama-rocm-vendor-*).
      # Those libraries expect libelf and libzstd from the system, which the
      # upstream FHS env lacks, so the hardware survey fails and the GPU is
      # never offered.
      # nix-ld does not help here: the FHS env brings its own dynamic loader.
      # The package only exposes `callPackage`, so inject a patched
      # appimageTools through it.
      lmstudio = prev.lmstudio.override {
        callPackage =
          path: args:
          final.callPackage path (
            args
            // {
              appimageTools = final.appimageTools // {
                wrapType2 =
                  wrapArgs:
                  final.appimageTools.wrapType2 (
                    wrapArgs
                    // {
                      extraPkgs =
                        pkgs:
                        wrapArgs.extraPkgs pkgs
                        ++ [
                          pkgs.elfutils
                          pkgs.zstd
                        ];
                    }
                  );
              };
            }
          );
      };
    })

    (final: prev: {
      # Claude Desktop >= 2.19675 links libpipewire directly from its native
      # binding, but upstream still lists pipewire only as a runtime (dlopen)
      # dependency, so auto-formatelf fails the build. Fixed here until
      # numtide/llm-agents.nix#10391 (or its successor) adds it to
      # buildInputs; drop this entry then.
      # The package only exposes `override`, so inject a stdenvNoCC that adds
      # pipewire to the unwrapped derivation (the darwin one has no
      # buildInputs and is left alone).
      llm-agents = prev.llm-agents // {
        claude-desktop = prev.llm-agents.claude-desktop.override {
          stdenvNoCC = prev.stdenvNoCC // {
            mkDerivation =
              args:
              prev.stdenvNoCC.mkDerivation (
                args
                // final.lib.optionalAttrs (args ? buildInputs) {
                  buildInputs = args.buildInputs ++ [ final.pipewire ];
                }
              );
          };
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
