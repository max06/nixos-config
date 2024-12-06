{
  lib,
  osConfig,
  ...
}:
with lib; {
  config = mkIf (osConfig.hostname == "monster") {
    programs.ssh = {
      matchBlocks = {
        docker1 = {
          hostname = "192.168.27.19";
          user = "max06";
          forwardAgent = true;
          identityFile = [".ssh/id_universe"];
        };
      };
    };
  };
}
