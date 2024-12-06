{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    ../../../system/video/nvidia
    ../../../system/secureboot.nix
    ../../../system/logitech
  ];

  config = {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/a0a11869-5de8-4a71-95cc-46cdc207c1d7";
        fsType = "btrfs";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/13AE-1DAE";
        fsType = "vfat";
        options = ["fmask=0022" "dmask=0022"];
      };
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024;
      }
    ];

    boot = {
      initrd = {
        availableKernelModules = ["sd_mod" "sr_mod"];
        kernelModules = [];
        luks.devices."crypted".device = "/dev/disk/by-uuid/c7d11b07-5448-42d3-a861-4d53ae58b563";
      };

      kernelModules = [];
      extraModulePackages = [];
      supportedFilesystems = ["ntfs"];

      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 32;
        efi.canTouchEfiVariables = true;
      };
    };

    networking.useNetworkd = true;
    systemd.network = {
      enable = true;
      netdevs = {
        "30-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
            MACAddress = "none";
          };
        };
      };
      networks = {
        "30-enp45s0" = {
          name = "enp45s0";
          bridge = ["br0"];
        };
        "30-br0" = {
          name = "br0";
          DHCP = "yes";
        };
      };
      links = {
        "30-br0" = {
          matchConfig = {
            OriginalName = "br0";
          };
          linkConfig = {
            MACAddressPolicy = "none";
          };
        };
      };
    };

    # Because special characters in luks passphrases can be complicated
    console.keyMap = "de";

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";

    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # TODO: Move to overlays
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };

    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
      tpm2-tools
      tpm2-tss
    ];

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };
      };
    };
    programs.virt-manager.enable = true;

    virtualisation.waydroid.enable = true;
    # TODO Automate it
    # nix-shell -p nur.repos.ataraxiasjel.waydroid-script

    # TODO: Move to module
    programs.steam.enable = true;

    # DO NOT TOUCH
    system.stateVersion = "23.11";
  };
}
