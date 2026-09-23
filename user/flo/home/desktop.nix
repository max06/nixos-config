# flo's home on desktop hosts: core layer plus Plasma, GUI apps and user
# services.
{ pkgs, ... }:
{
  imports = [
    ./core.nix
    ../../modules/browsers/vivaldi.nix
    ../../modules/cloud/synology-drive.nix
    ../../modules/notes/obsidian.nix
    ../../modules/security/gnupg
  ];

  home.username = "flo";
  home.homeDirectory = "/home/flo";

  # ------------------------------------------------------------- development
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-vscode.vscode-speech
    ];
  };

  # ---------------------------------------------------------------- services
  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  # ---------------------------------------------------------------- packages
  home.packages = with pkgs; [
    # desktop apps
    floorp-bin
    chromium
    libreoffice-qt-stable
    slack
    discord
    element-desktop
    tidal-hifi
    vlc
    fastmail-desktop
    keybase-gui
    kdePackages.yakuake
    kdePackages.filelight
    maliit-keyboard
    virt-viewer
    cage

    # lab / ML
    gns3-gui
    lmstudio
    nvtopPackages.amd

    # cli / dev tooling
    pass
    gnumake
    gcc
    go
    act
    sshpass
    nix-output-monitor
    nvd
  ];

  # ------------------------------------------------------------------ plasma
  programs.plasma = {
    enable = true;

    workspace.lookAndFeel = "org.kde.breezedark.desktop";

    input.keyboard = {
      layouts = [
        {
          layout = "de";
          variant = "deadacute";
        }
        { layout = "de"; }
        { layout = "us"; }
      ];
      numlockOnStartup = "on";
    };

    kwin = {
      virtualDesktops = {
        number = 2;
        rows = 1;
        names = [
          "Private"
          "Work"
        ];
      };
      nightLight = {
        enable = true;
        temperature.night = 3800;
      };
    };

    powerdevil.AC = {
      autoSuspend.action = "nothing";
      powerButtonAction = "shutDown";
      turnOffDisplay.idleTimeout = "never";
    };

    kscreenlocker.autoLock = false;

    session.sessionRestore = {
      restoreOpenApplicationsOnLogin = "startWithEmptySession";
      excludeApplications = [ "code" ];
    };

    shortcuts = {
      kwin."Walk Through Windows" = [
        "Alt+Tab"
        "Meta+Tab"
      ];
      kwin."Walk Through Windows (Reverse)" = [
        "Alt+Shift+Tab"
        "Meta+Shift+Tab"
      ];
      yakuake."toggle-window-state" = "Meta+Del";
    };

    configFile = {
      # No hot corner for the overview effect.
      kwinrc.Effect-overview.BorderActivate = 9;
      kwinrc.Windows.CenterSnapZone = 10;
      kwinrc.Wayland.VirtualKeyboardEnabled = true;

      # Custom tiling layouts (Meta+T), one entry per output/desktop
      # combination. Left 25% / center 50% / right 25%, some with a split
      # right column.
      kwinrc.Tiling.padding = 4;
      kwinrc."Tiling/23d84027-6b81-5a63-91b8-8e7e614d6fad".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/2798561c-85b6-4add-9d62-e7314f60f373/1db00706-ecff-46b4-8a24-fa953498fa36".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/2798561c-85b6-4add-9d62-e7314f60f373/7a652ab8-a8a2-45fe-85a5-fc4e6395195c".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/2798561c-85b6-4add-9d62-e7314f60f373/9025ffeb-edb1-4927-802c-45244e6a95aa".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/2798561c-85b6-4add-9d62-e7314f60f373/990cb560-2e1d-4799-853e-08389ea7e168".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.23593750000000002},{\"width\":0.5140624999999996}]}";
      kwinrc."Tiling/4b639d2d-ecbc-558a-8902-79da0c0147ae".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/4d02e28e-85b1-545d-9696-31a99639e08f".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/85ab9ddf-d79a-426d-a237-51af53e9e300/1db00706-ecff-46b4-8a24-fa953498fa36".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/85ab9ddf-d79a-426d-a237-51af53e9e300/7a652ab8-a8a2-45fe-85a5-fc4e6395195c".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/85ab9ddf-d79a-426d-a237-51af53e9e300/9025ffeb-edb1-4927-802c-45244e6a95aa".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/85ab9ddf-d79a-426d-a237-51af53e9e300/990cb560-2e1d-4799-853e-08389ea7e168".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/892d9657-38cb-5a7f-8ed5-7d2399cbb33e".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/8c1e88a8-8316-5691-9faa-44f935dbd228".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.4722222222222222},{\"height\":0.527777777777777}],\"width\":0.25}]}";
      kwinrc."Tiling/92e842d7-5928-5c43-884a-4912e7cc82ed".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/9c45c7ae-01d7-542d-adf0-6552eb05840a".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/b4addc6a-73f4-50c9-91d2-f467f1a6f039".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/bda4fdbf-610f-429e-afcf-0a55ccd20172/990cb560-2e1d-4799-853e-08389ea7e168".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/bf215e3b-b58c-5c4a-8c32-96981be0137c".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"layoutDirection\":\"vertical\",\"tiles\":[{\"height\":0.5},{\"height\":0.5}],\"width\":0.25}]}";
      kwinrc."Tiling/c73684f0-83c4-5586-b5c5-86ac66d58d6c".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/d02c035d-eef0-5c68-aa2f-2e83d0ba08b1".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/d3b3d9bc-06de-5748-bbfe-56dd26acb3ce".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/dc8a429a-3ed8-59c7-afe5-afa88380c5fc".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      kwinrc."Tiling/e1c4681b-2a2a-5068-b618-cd8881665755".tiles =
        "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";

      # Mouse: flat acceleration, faster scrolling on the MX Master 3.
      kcminputrc.Mouse.X11LibInputXAccelProfileFlat = true;
      kcminputrc."Libinput/1133/16514/Logitech MX Master 3".ScrollFactor = 1;
      kcminputrc."Libinput/1133/45091/Logitech Wireless Mouse MX Master 3".ScrollFactor = 1.5;

      # No volume-change beep, no kwallet first-run wizard.
      plasmaparc.General.AudioFeedback = false;
      kwalletrc.Wallet."First Use" = false;

      # Don't nag about the browser integration, don't auto-mount media.
      kded5rc.Module-browserintegrationreminder.autoload = false;
      kded5rc.Module-device_automounter.autoload = false;

      # Spectacle: rectangular region by default, quit after saving.
      spectaclerc.GuiConfig.captureMode = 0;
      spectaclerc.GuiConfig.quitAfterSaveCopyExport = true;
    };
  };
}
