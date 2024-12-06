{
  lib,
  osConfig,
  ...
}:
with lib; {
  config = mkIf (osConfig.hostname == "monster") {
    programs.ssh = {
      matchBlocks = {
        router = {
          hostname = "192.168.27.1";
          user = "flo";
          port = 2222;
          forwardAgent = true;
          identityFile = [".ssh/id_universe"];
        };
      };
    };
  };
}
