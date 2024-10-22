{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      pinentry-qt
      kdePackages.kleopatra
    ];

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      enableExtraSocket = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };
}
