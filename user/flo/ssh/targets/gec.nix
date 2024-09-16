{
  lib,
  osConfig,
  ...
}:
with lib; {
  config = mkIf (osConfig.hostname == "monster") {
    programs.ssh = {
      matchBlocks = {
        gec = {
          hostname = "192.168.27.17";
          user = "flo";
          dynamicForwards = [{port = 8123;}];
          forwardAgent = true;
          identityFile = [".ssh/id_universe"];
        };
      };
    };
  };
}
