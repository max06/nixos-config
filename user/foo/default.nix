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
      type = with types; listOf (enum ["foo"]);
    };
  };
}
