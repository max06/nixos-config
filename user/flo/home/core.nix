# Portable part of flo's home: shell and CLI tools. Used on the desktop and
# inside devcontainers (see flake.nix `homeConfigurations`). Must not depend
# on systemd, a display, or host secrets.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/shells/fish
    ../../modules/shells/starship.nix
    ../../modules/kubernetes/kubeswitch.nix
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
    # Standalone home-manager (devcontainers) installs packages into the
    # user's nix profile, which the container's default PATH does not
    # include. Add it here; on NixOS this resolves to the per-user profile
    # that is already on PATH, so it is harmless there.
    home.sessionPath = [ "${config.home.profileDirectory}/bin" ];

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
