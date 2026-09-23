{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    virtualisation.proxmox = {
      node = "srv-pm01";
      autoInstall = true;
      memory = 4096;
      cores = 4;
      sockets = 1;
      net = [
        {
          model = "virtio";
          bridge = "vmbr0";
        }
      ];
      scsi = [ { file = "localstore:40"; } ];
    };

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                priority = 1;
                name = "ESP";
                start = "1M";
                end = "128M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };

    boot = {
      initrd = {
        kernelModules = [ ];
      };

      kernelModules = [ ];
      extraModulePackages = [ ];

      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 16;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
