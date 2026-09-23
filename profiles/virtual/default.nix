# Any QEMU/KVM guest (Proxmox, plain qemu).
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  services.qemuGuest.enable = true;
}
