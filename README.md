# nixos-config

NixOS flake for my machines: one desktop and a couple of Proxmox VMs.
Hosts are grouped by role (`desktop`, `server`); each group carries defaults,
each host adds hardware and its own services on top.

```
flake.nix               inputs, host groups, checks, devShell
lib/mkNixos.nix         group + hostname -> nixosSystem
inventory/              default.nix (all hosts) / <group>/default.nix / <group>/<host>.nix
profiles/virtual/       modules for VM guests (qemu-guest, declarative Proxmox VM)
system/                 reusable NixOS modules (audio, bluetooth, secureboot, logitech, ...)
user/                   accounts (hostUsers option) and home-manager config
overlays/               nixpkgs overlays
secrets/                sops-encrypted values (see below)
```

## Hosts

| host      | group   | what                                             |
| --------- | ------- | ------------------------------------------------ |
| `monster` | desktop | physical workstation, KDE Plasma, libvirt, GNS3  |
| `rancher` | server  | Proxmox VM, single-node RKE2                     |
| `pw`      | server  | Proxmox VM for work (declared, not installed yet) |

## Everyday use

```sh
nix develop                  # or `direnv allow` once; gives nixfmt, nixd, sops, age
nix flake check --no-build   # evaluate every host
nix fmt                      # format

# on monster
nh os switch                 # flake path is configured in programs.nh

# servers (over SSH, as root)
nixos-rebuild switch --flake .#rancher --target-host root@rancher
```

## Secrets

Secrets live in `secrets/*.yaml`, encrypted with [sops](https://github.com/getsops/sops)
and consumed through [sops-nix](https://github.com/Mic92/sops-nix).
Recipients are listed in `.sops.yaml`: my gpg key for editing, plus one age
key per host (derived from its SSH host key) so the host can decrypt at
activation without gpg.

First-time setup:

```sh
# 1. collect the hosts' age public keys and put them into .sops.yaml
ssh-keyscan -t ed25519 monster | ssh-to-age
ssh-keyscan -t ed25519 rancher | ssh-to-age

# 2. create the users file (opens $EDITOR, encrypts on save)
mkdir -p secrets
sops secrets/users.yaml
```

`secrets/users.yaml` layout:

```yaml
flo:
  hashed-password: "$6$..."   # from `mkpasswd -m sha-512`
```

Once the file exists, `user/flo/default.nix` picks it up and sets the login
password from it. Without it, existing hosts keep their current password
and new hosts are SSH-key only.

After adding a host: add its age key to `.sops.yaml`, then
`sops updatekeys secrets/users.yaml`.

## Devcontainers

The portable part of my home (`user/flo/home/core.nix`: fish, network and
CLI tools) is also exposed as standalone home-manager profiles for VS Code
devcontainers, so a single repository serves the desktop and every
container. Git identity and SSH config are left out there (`isDevContainer`
option); VS Code injects those on container creation.

VS Code settings:

```json
"dotfiles.repository": "max06/nixos-config",
"dotfiles.targetPath": "~/dotfiles",
"dev.containers.defaultFeatures": {
  "ghcr.io/devcontainers/features/nix:1": {
    "extraNixConfig": "experimental-features = nix-command flakes"
  }
}
```

`install.sh` runs after the clone. It picks `homeConfigurations.<user>` for
the usual container usernames (`vscode`, `node`, `root`, `codespace`,
`ubuntu`, `coder`) and otherwise falls back to `homeConfigurations.container`,
which reads user and home from the environment with `--impure`.

Activation also seeds `~/.kube/switch-config.yaml` for kubeswitch if it does
not exist yet. The file is meant to be extended by hand (Rancher stores need
an inline token) and is never overwritten.

## Installing a new VM

Create the VM in Proxmox (UEFI, TPM, boot from the NixOS installer ISO or
PXE), then from this repository:

```sh
nix run github:nix-community/nixos-anywhere -- --flake .#<host> root@<ip>
```

The `disko` layout comes from the host file (`rancher`) or from
`profiles/virtual/proxmox-vm.nix` (`pw`).
