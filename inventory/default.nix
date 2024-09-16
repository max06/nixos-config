{
  config,
  lib,
  hostname,
  ...
}:
with lib; {
  options.hostname = mkOption {
    type = types.str;
  };

  imports = [
    ../user
    ../system/common
  ];

  config = {
    inherit hostname;

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";

    networking.hostName = mkDefault hostname;
    networking.useDHCP = mkDefault true;

    # foo.users = ["foo"];
  };
}
