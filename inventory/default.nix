{
  config,
  lib,
  hostname,
  ...
}: {
  options.hostname = lib.mkOption {
    type = lib.types.str;
  };

  config = {
    inherit hostname;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    networking.hostName = hostname;
  };
}
