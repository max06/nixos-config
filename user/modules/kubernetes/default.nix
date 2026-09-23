# Kubernetes client tooling for the portable profile. kubectl itself comes
# from the host or the devcontainer image.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  krewRoot = "${config.home.homeDirectory}/.krew";
in
{
  imports = [ ./kubeswitch.nix ];

  programs.k9s.enable = true;

  home.packages = with pkgs; [
    krew
    kubectl-node-shell # kubectl node-shell, packaged; no krew needed
  ];

  # krew installs plugins below ~/.krew; kubectl finds them via PATH.
  home.sessionPath = [ "${krewRoot}/bin" ];

  # netshoot is not in nixpkgs, so it is installed through krew. Best effort:
  # needs network, and a failure must not break activation.
  home.activation.installKrewPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${krewRoot}/receipts/netshoot.yaml" ]; then
      run ${pkgs.krew}/bin/krew install netshoot \
        || echo "warning: krew plugin install failed (offline?); run 'kubectl krew install netshoot' later"
    fi
  '';
}
