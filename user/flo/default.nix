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
    home.stateVersion = "24.05";
  };
}
