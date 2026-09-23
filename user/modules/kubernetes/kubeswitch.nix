# kubeswitch: fast kubeconfig context switching.
#
# The package installs the `switcher` binary and its completions. The shell
# function that actually changes the context comes from `switcher init`; in
# fish it is called `kubeswitch` because `switch` is a reserved word.
{ lib, pkgs, ... }:
let
  # Starting point for ~/.kube/switch-config.yaml. kubeswitch has no include
  # mechanism and store credentials (e.g. Rancher tokens) can only live
  # inline, so the file has to stay hand-editable. It is therefore seeded
  # once and never touched again by home-manager.
  seedConfig = pkgs.writeText "switch-config.yaml" ''
    kind: SwitchConfig
    version: v1alpha1
    kubeconfigStores:
      - kind: filesystem
        paths:
          - ~/.kube/config
  '';
in
{
  home.packages = [ pkgs.kubeswitch ];

  programs.fish = {
    interactiveShellInit = ''
      switcher init fish | source
      # The init script only registers completions for `switcher`; let the
      # `kubeswitch` function (and the `s` alias wrapping it) reuse them.
      complete -c kubeswitch -w switcher
    '';
    # `alias` wraps the target, so `s` inherits kubeswitch's completions.
    shellAliases.s = "kubeswitch";
  };

  home.activation.seedKubeswitchConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.kube/switch-config.yaml"
    if [ ! -e "$target" ]; then
      run mkdir -p "$HOME/.kube"
      run cp "${seedConfig}" "$target"
      run chmod u+w "$target"
    fi
  '';
}
