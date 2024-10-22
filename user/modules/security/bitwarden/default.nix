{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      bitwarden-desktop
    ];
  };
}
