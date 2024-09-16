{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options = {
    foo.users = mkOption {
      type = with types; listOf (enum ["flo"]);
    };
  };

  config = mkIf (builtins.elem "flo" config.foo.users) {
    users.users.flo = {
      isNormalUser = true;
      extraGroups = ["wheel" "libvirtd"]; # Enable ‘sudo’ for the user.
      initialPassword = "topsecret";
    };

    programs.fish.enable = true;

    home-manager.users.flo = import ./home.nix;
  };
}
