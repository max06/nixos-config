{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra # formatter
    nixd
    home-manager # Lets us run commands like `home-manager switch`
  ];
}
