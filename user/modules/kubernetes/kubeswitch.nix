# kubeswitch: fast kubeconfig context switching.
#
# The package installs the `switcher` binary and its completions. The shell
# function that actually changes the context comes from `switcher init`; in
# fish it is called `kubeswitch` because `switch` is a reserved word.
{ pkgs, ... }:
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
}
