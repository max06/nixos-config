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

  config = {
    inherit hostname;

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";

    networking.hostName = mkDefault hostname;
    networking.useDHCP = mkDefault true;

    networking.hostName = hostname;
  };
}
