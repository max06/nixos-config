# Nixos Deployments and stuff

Definitely overly complicated. Contains more than necessary.

## Workstation

## Virtual machines

### Bootstrap

Create new virtual machine (Hyper-V, Openstack, Proxmox), from template if available.

Make sure:

- UEFI is enabled
- Secure boot is in setup mode
- TPM is enabled
- Boot order: Disk, PXE

First boot: Start from PXE. Select nixos unstable live environment. Set password after boot.

```sh {"name":"bootstrap-guest","promptEnv":"always","terminalRows":"13"}
#!/usr/bin/env bash

# CAUTION: It will erase whatever is running on that machine!
export TYPE=[Guest type \(hyperv,proxmox,openstack\)]
export TARGET=[IP of waiting server]
nix run github:nix-community/nixos-anywhere -- --flake .#guest-"$TYPE" root@"$TARGET"

```