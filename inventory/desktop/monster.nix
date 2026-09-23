# monster: physical desktop. AMD CPU + AMD GPU, LUKS root unlocked via TPM2,
# Secure Boot through lanzaboote. Also hosts VMs (libvirt), containers
# (docker) and a GNS3 lab.
{
  inputs,
  pkgs,
  pkgs-master,
  modulesPath,
  ...
}:
{
  imports = [
    # No generated hardware-configuration.nix; keep the broad module set so
    # the initrd can find the disks.
    (modulesPath + "/profiles/all-hardware.nix")
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../system/secureboot.nix
    ../../system/logitech
  ];

  # ---------------------------------------------------------------- storage
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a0a11869-5de8-4a71-95cc-46cdc207c1d7";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/13AE-1DAE";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  # zram first (priority 100), swapfile as overflow (priority 10).
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25; # ~16 GB of compressed capacity, uses ~5-8 GB RAM at typical ratios
    priority = 100;
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
      options = [ "discard" ];
      priority = 10;
    }
  ];

  # ------------------------------------------------------------------- boot
  boot = {
    initrd = {
      availableKernelModules = [
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ "lz4" ];
      luks.devices."crypted" = {
        device = "/dev/disk/by-uuid/c7d11b07-5448-42d3-a861-4d53ae58b563";
        allowDiscards = true;
        crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-measure-pcr=yes" # extend PCR 15 with volume key -> detectable
        ];
      };
      systemd.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "zswap.enabled=0" ]; # zram is used instead of zswap
    kernel.sysctl = {
      "vm.swappiness" = 150; # >100 is fine for zram (kernel allows up to 200): swap early and cheaply
      "vm.page-cluster" = 0; # no swap readahead; zram has no seek cost
    };
    supportedFilesystems = [ "ntfs" ];

    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 8;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
    };

    # Run aarch64 binaries (docker buildx etc.) through a static qemu-user.
    # Taken from nixpkgs master because the fix landed there first and
    # Hydra already built it.
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    binfmt.preferStaticEmulators = true; # Make it work with Docker
    binfmt.registrations."aarch64-linux" = {
      interpreter = "${pkgs-master.pkgsStatic.qemu-user}/bin/qemu-aarch64";
      fixBinary = true;
      matchCredentials = true;
    };
  };

  # --------------------------------------------------------------- hardware
  hardware.amdgpu.initrd.enable = true;
  hardware.ksm.enable = true; # same-page merging across VMs

  systemd.coredump.settings.Coredump = {
    ProcessSizeMax = "4G";
    ExternalSizeMax = "4G";
    Compress = "yes";
  };

  # ---------------------------------------------------------------- network
  networking.nftables.enable = true;
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    netdevs."30-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
        MACAddress = "none";
      };
    };
    networks = {
      "30-enp45s0" = {
        name = "enp45s0";
        bridge = [ "br0" ];
      };
      "30-br0" = {
        name = "br0";
        DHCP = "yes";
        # Search domain for the server VLAN, so `ssh rancher` and
        # `--target-host rancher` resolve. The VLAN's resolver only answers
        # for the FQDN.
        domains = [ "srv.hive.internal" ];
        dhcpV4Config.UseDomains = true;
        ipv6AcceptRAConfig.UseDNS = false;
        dhcpV6Config.UseDNS = false;
      };
    };
    links."30-br0" = {
      matchConfig.OriginalName = "br0";
      linkConfig.MACAddressPolicy = "none";
    };
  };
  networking.interfaces.enp45s0.wakeOnLan.enable = true;
  networking.interfaces.br0.wakeOnLan.enable = true;

  networking.firewall.interfaces."virbr0" = {
    allowedUDPPorts = [
      53
      67
    ];
    allowedTCPPorts = [ 53 ];
  };

  services.avahi.enable = true;

  services.openiscsi = {
    enable = true;
    name = "iqn.2020-08.internal.hive.monster:initiator";
    discoverPortal = "192.168.30.11:3260";
    enableAutoLoginOut = true;
  };

  # --------------------------------------------------------- virtualisation
  virtualisation.docker = {
    enable = true;
    # Docker >= 27 manages ip6tables by default and, being the one that has
    # to enable IPv6 forwarding, sets the ip6 FORWARD policy to drop. It also
    # loads br_netfilter, which sends frames bridged between enp45s0 and the
    # libvirt taps on br0 through that same chain, so VMs lose every IPv6
    # packet beyond the host (no RAs, no neighbour discovery). IPv4 is spared
    # only because libvirt enables IPv4 forwarding first. Docker networks
    # here carry no IPv6, so dropping its ip6tables management costs nothing.
    daemon.settings.ip6tables = false;
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs-master.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
    onShutdown = "shutdown";
    onBoot = "ignore";
  };
  programs.virt-manager.enable = true;
  virtualisation.waydroid.enable = true;

  services.gns3-server = {
    enable = true;
    ubridge.enable = true;
    dynamips.enable = true;
  };

  users.users.flo.extraGroups = [
    "libvirtd"
    "docker"
    "ubridge"
    "wireshark"
  ];

  # ------------------------------------------------------------------ tools
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 8";
    flake = "/home/flo/SynoDrive/nixos-config";
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # Qt GUI
  };

  # Run unpatched binaries (ROCm-linked ML tooling, downloaded CLIs).
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    rocmPackages.clr
    rocmPackages.rocblas
    rocmPackages.hipblas
    stdenv.cc.cc.lib
    gcc
    pkgs-master.util-linux
    alsa-lib
    numactl
    zstd
    libdrm
    elfutils
  ];
  # Many ROCm-linked binaries hardcode /opt/rocm.
  systemd.tmpfiles.rules = [ "L+ /opt/rocm - - - - ${pkgs.rocmPackages.clr}" ];

  # System-level tools: needed by root, services, or hardware setup.
  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm2-tss
    docker-compose
    vulkan-tools
    gdb
    inetutils
  ];

  # DO NOT TOUCH
  system.stateVersion = "23.11";
}
