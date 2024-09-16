{lib, ...}:
with lib; {
  imports = [
    ./targets/gec.nix
  ];

  config = {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };

    services.ssh-agent.enable = true;
    # TODO: Don't use hardcoded path
    home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
  };
}
