{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra # formatter
    home-manager # Lets us run commands like `home-manager switch`
  ];
}
