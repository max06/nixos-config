# pw: work VM on Proxmox (not installed yet). Meant to replace the current
# Ubuntu VM that runs strongSwan, tailscale and docker for devcontainers.
{ ... }:
{
  imports = [
    ../../profiles/virtual
    ../../profiles/virtual/proxmox-vm.nix
  ];

  virtualisation.docker.enable = true;
  users.users.flo.extraGroups = [ "docker" ];

  # Set to the NixOS release current at first install; never change afterwards.
  system.stateVersion = "26.05";
}
