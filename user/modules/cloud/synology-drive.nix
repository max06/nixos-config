{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  config = {
    home.packages = with pkgs; [
      synology-drive-client
    ];

    # TODO: Make service autostart
    systemd.user.services.synologyDrive = {
      Unit = {
        Description = "Synology Drive Client";
        SourcePath = "${pkgs.synology-drive-client}/share/applications/synology-drive.desktop";
        Wants = ["default.target"];
        After = ["default.target"];
      };
      Service = {
        Type = "simple";
        ExitType = "cgroup";
        Slice = "app.slice";
        ExecStart = "${pkgs.synology-drive-client}/bin/synology-drive start";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
