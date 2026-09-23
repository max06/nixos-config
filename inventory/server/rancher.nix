# rancher: Proxmox VM running a single-node RKE2 cluster.
{ pkgs, ... }:
{
  imports = [ ../../profiles/virtual ];

  # Installed with disko: ESP + LVM volume group "pool" with an ext4 root.
  services.lvm.enable = true;
  disko.devices = {
    disk.main = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "500M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          primary = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs.root = {
        size = "100%FREE";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
          mountOptions = [ "defaults" ];
        };
      };
    };
  };

  services.rke2 = {
    enable = true;
    cni = "cilium";
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--write-kubeconfig=/root/.kube/config"
      "--cluster-cidr=10.44.0.0/16"
      "--service-cidr=10.45.0.0/16"
      "--cluster-dns=10.45.0.10"
      "--cluster-domain=cluster.local"
      "--ingress-controller=traefik"
      "--enable-servicelb"
    ];
  };
  # RKE2 / cilium manage their own rules; the NixOS firewall gets in the way.
  networking.firewall.enable = false;
  networking.domain = "srv.hive.internal";

  environment.systemPackages = [ pkgs.kubectl ];

  # DO NOT TOUCH: first generation was installed from 25.11.
  system.stateVersion = "25.11";
}
