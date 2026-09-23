# Fish as the interactive shell, with bash kept as login shell for
# compatibility: interactive bash hands over to fish.
{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.bash.enable = true;

  programs.bash.initExtra = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
}
