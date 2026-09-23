# kubeswitch: fast kubeconfig context switching.
#
# The package installs the `switcher` binary and its completions. The shell
# function that actually changes the context comes from `switcher init`; in
# fish it is called `kubeswitch` because `switch` is a reserved word.
{ lib, pkgs, ... }:
let
  # `switcher init fish` prints the `kubeswitch` function followed by a copy
  # of the completion script. Only the function is kept; the completions come
  # from the vendor file the package ships, which fish autoloads on first use.
  #
  # Sourcing the whole init output at shell start (the documented way) breaks
  # completion for the entire session under home-manager: the script's
  # `complete --do-complete "switcher "` makes fish autoload the vendor file
  # right away, home-manager then appends to `fish_complete_path` at the end
  # of config.fish, and fish reacts to that by dropping all completions of
  # every autoloaded command without ever loading the file again.
  #
  # The output does not depend on the environment, so it is extracted once at
  # build time and installed as an autoloaded function file.
  kubeswitchFunction = pkgs.runCommand "kubeswitch.fish" { } ''
    ${pkgs.kubeswitch}/bin/switcher init fish \
      | sed '/^# fish completion for switcher/,$d' > "$out"
  '';

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

  xdg.configFile."fish/functions/kubeswitch.fish".source = kubeswitchFunction;

  programs.fish = {
    interactiveShellInit = ''
      # The vendor completions are registered for `switcher` only; let the
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
