{modulesPath, ...}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  config = {
    boot = {
      initrd = {
        kernelModules = [];
      };

      kernelModules = [];
      extraModulePackages = [];

      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 32;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
