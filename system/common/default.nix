# Baseline tooling every host should have in a root shell.
{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    jq
    btop
    file
    pv
  ];
}
