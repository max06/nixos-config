{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    ../../../system/common
    ../../../system/video/nvidia
    ../../../system/secureboot.nix
  ];

  config = {
    boot.initrd.availableKernelModules = ["sd_mod" "sr_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];
    boot.supportedFilesystems = ["ntfs"];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/a0a11869-5de8-4a71-95cc-46cdc207c1d7";
      fsType = "btrfs";
    };

    boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/c7d11b07-5448-42d3-a861-4d53ae58b563";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/13AE-1DAE";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.eth0.useDHCP = lib.mkDefault true;

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    # networking.hostName = "monster"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    # Set your time zone.
    # time.timeZone = "Europe/Amsterdam";
    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    # Select internationalisation properties.
    # i18n.defaultLocale = "en_US.UTF-8";
    console = {
      #   font = "Lat2-Terminus16";
      keyMap = "de";
      #   useXkbConfig = true; # use xkb.options in tty.
    };
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    # Enable the Plasma 5 Desktop Environment.
    services.displayManager.sddm.enable = true;
    # services.xserver.desktopManager.plasma5.enable = true;
    services.desktopManager.plasma6.enable = true;
    # Configure keymap in X11
    # services.xserver.xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";
    # Enable CUPS to print documents.
    # services.printing.enable = true;
    # Enable sound.
    # sound.enable = true;
    # hardware.pulseaudio.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.flo = {
      isNormalUser = true;
      extraGroups = ["wheel" "libvirtd"]; # Enable ‘sudo’ for the user.
      initialPassword = "topsecret";
      packages = with pkgs; [
        chromium
        vscode
        ((vivaldi.overrideAttrs (oldAttrs: {
            dontWrapQtApps = false;
            dontPatchELF = true;
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.kdePackages.wrapQtAppsHook];
          }))
          .override {
            commandLineArgs = ''
              -enable-features=UseOzonePlatform
              --ozone-platform=wayland
              --ozone-platform-hint=auto
              --enable-features=WaylandWindowDecorations
            '';
          })
      ];
    };
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      pkgs.sbctl
      git
      slack
      discord
      zoom-us
      tidal-hifi
      tpm2-tools
      virt-viewer
      maliit-keyboard
      libsForQt5.qt5.qtwayland
      tpm2-tss
      synology-drive-client
      cage
      nvd
      # element-desktop-1-11-73.element-desktop
      element-desktop
      libunity
      nixpkgs-fmt
    ];
    # nix-shell -p nur.repos.ataraxiasjel.waydroid-script
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    # List services that you want to enable:
    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # system.copySystemConfiguration = true;
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "23.11"; # Did you read the comment?

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
    # Load nvidia driver for Xorg and Wayland
    # services.xserver.videoDrivers = ["nvidia"];

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    virtualisation.waydroid.enable = true;
  };
}
