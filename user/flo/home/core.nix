# Portable part of flo's home: shell and CLI tools. Used on the desktop and
# inside devcontainers (see flake.nix `homeConfigurations`). Must not depend
# on systemd, a display, or host secrets.
{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/shells/fish
    ./git.nix
    ../ssh
  ];

  options.isDevContainer = lib.mkEnableOption "running inside a devcontainer" // {
    description = ''
      Set for devcontainer home configurations. Disables everything VS Code
      already provides in a container (git identity, credential helper, ssh
      config, agent forwarding).
    '';
  };

  config = {
    home.packages = with pkgs; [
      # network diagnostics
      dnsutils # dig, nslookup
      iproute2 # ip, ss
      tcpdump
      mtr
      nmap

      # everyday cli
      jq
      btop
    ];

    # home-manager release this configuration was created with. Do not change.
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };
}
