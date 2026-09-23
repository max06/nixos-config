# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Personal NixOS flake for Flo's (`max06`) machines: one physical desktop
(`monster`) and Proxmox VMs (`rancher`, `pw`). Hosts are sorted into
**groups** (`desktop`, `server`) with group defaults and per-host files.
Home-manager runs as a NixOS module; plasma-manager configures KDE for the
`flo` user on desktops only.

Remote: `github.com/max06/nixos-config`, public. History was restarted from
a single commit on 2026-09-23 after the cleanup; do not resurrect the old
history. Push only when Flo asks.

## Layout

```
flake.nix               inputs, host groups, checks, devShell
lib/mkNixos.nix         groups -> nixosConfigurations; specialArgs + base modules
inventory/default.nix   every host (imports ../user and ../system/common)
inventory/<group>/default.nix   group defaults
inventory/<group>/<host>.nix    host: hardware, filesystems, services
profiles/virtual/       VM guest modules (qemu-guest; proxmox-vm = disko + VM spec)
system/<topic>/         reusable NixOS modules (audio, bluetooth, secureboot, logitech, common)
user/default.nix        home-manager wiring + `hostUsers` option
user/flo/               account (default.nix), keys.nix, ssh/, home/{core,git,desktop,container}.nix
install.sh              devcontainer dotfiles hook -> homeConfigurations.<user>
user/modules/<topic>/   reusable home-manager modules
overlays/default.nix    nixpkgs overlays (vivaldi from nixpkgs-master)
secrets/                sops files (not present until Flo creates them)
.sops.yaml              recipients: Flo's gpg key + age key per host
```

Module order per host (`lib/mkNixos.nix`): inline base → overlays → disko →
sops-nix → proxmox-nixos → `inventory/` → `inventory/<group>/` →
`inventory/<group>/<host>.nix`.

`specialArgs`: `inputs`, `pkgs-stable`, `pkgs-master`, `pkgs-staging`,
`pkgs-pinned`. The extra channels are deliberate fallbacks for broken or
not-yet-propagated packages. Each import costs eval time; use sparingly.

## Conventions

- **`hostUsers`** (enum-merge pattern): `user/default.nix` declares
  `listOf (enum [])`, each account module (`user/flo/default.nix`) re-declares
  it with its own name added. A host lists the accounts it wants. The account
  module creates the NixOS user + SSH keys; home-manager is attached only by
  the desktop group (`home-manager.users.flo = import ../../user/flo/home.nix`).
- **Home layers**: `user/flo/home/core.nix` is the portable layer (fish, CLI
  tools) and must stay free of `services.*`, GUI packages and secrets, because
  it is also built standalone for devcontainers (`homeConfigurations` in
  flake.nix, one per common container username plus an impure `container`
  fallback). `desktop.nix` adds Plasma, GUI apps and user services and is what
  the desktop group attaches. The `isDevContainer` option gates git and ssh
  config, which VS Code provides inside containers.
- SSH public keys are defined once in `user/flo/keys.nix` (plain list).
- Host-specific home-manager config keys off `osConfig.networking.hostName`.
- Passwords come from sops (`secrets/users.yaml`, key `flo/hashed-password`).
  The wiring is guarded by `builtins.pathExists`, so the repo evaluates
  before the secret file exists. Never put plaintext passwords in the tree.
- Package scope: `environment.systemPackages` only for what root, services or
  hardware setup need; everything else in `home.packages`. Baseline root
  tools are in `system/common`.
- plasma-manager: prefer typed options (`kwin.*`, `input.*`, `session.*`,
  `shortcuts`). `configFile` is only for things without a typed option (the
  tiling layouts, mouse scroll factors). Never paste raw `rc2nix` dumps.
- Formatter: `nixfmt` via `nix fmt`. Format files you touch.
- `system.stateVersion` values are deliberate. Never change them.
- Remove dead code instead of commenting it out.

## Commands

```bash
nix flake check --no-build        # evaluates every host (fast, run after each change)
nix eval --raw .#nixosConfigurations.monster.config.system.build.toplevel.drvPath
nix eval --raw '.#nixosConfigurations.monster.config.home-manager.users.flo.home.file.".ssh/config".text'
nix fmt
```

Nix only sees **git-tracked** files in a flake. Stage new files (`git add`)
before evaluating, or evaluation fails with "is not tracked by Git".

## Working rules

- Ask before touching secrets, disks (`disko`, `fileSystems`, `luks`), boot
  (`lanzaboote`, `systemd-boot`), or `stateVersion`.
- No push/fetch to the remote. No attempt to reach any host in the inventory.
- Prefer upstream NixOS / home-manager / plasma-manager options over raw text.
- Small, reviewable steps; re-check evaluation after each.

## State (2026-09-23)

- All hosts evaluate cleanly; `nix flake check --no-build` passes.
- monster and rancher run this config with sops-provided passwords.
- Plasma: only deliberate settings were kept; a fresh `rc2nix` dump can be
  diffed against `user/flo/home/desktop.nix` if something is missing.
- `pw` stateVersion was set to 26.05 as a placeholder for its first install.
- The iSCSI initiator name was neutralised on 2026-09-23; if the target
  enforces an initiator allowlist it needs the new name.
- monster switched from NVIDIA to AMD GPU on 2026-09-19; nvidia module removed.
- Deployment tooling (colmena, deploy-rs, nixos-generators images) was removed;
  a proper remote-deploy setup is planned as a separate task.
