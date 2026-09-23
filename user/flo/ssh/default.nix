# SSH client configuration. Uses upstream ssh_config directive names
# (programs.ssh.settings); each attribute is a Host block. Skipped in
# devcontainers, where VS Code forwards the host's agent and config.
{
  config,
  lib,
  osConfig ? { },
  ...
}:
{
  config = lib.mkIf (!config.isDevContainer) {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*" = {
          ForwardAgent = true;
          AddKeysToAgent = "yes";
        };
      }
      # Lab and home network targets, only useful from the desktop.
      // lib.optionalAttrs ((osConfig.networking.hostName or null) == "monster") {
        lab = {
          HostName = "192.168.27.17";
          User = "flo";
          IdentityFile = "~/.ssh/id_universe";
          DynamicForward = 8123;
        };
        docker1 = {
          HostName = "192.168.27.19";
          User = "max06";
          IdentityFile = "~/.ssh/id_universe";
        };
        router = {
          HostName = "192.168.27.1";
          Port = 2222;
          User = "flo";
          IdentityFile = "~/.ssh/id_universe";
        };
        pw = {
          HostName = "192.168.30.52";
          User = "flo";
          IdentityFile = "~/.ssh/id_universe";
          DynamicForward = 8123;
          # Forward the local gpg agent so signing and decryption work remotely.
          RemoteForward = [
            "/run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra"
            "/run/user/1000/gnupg/S.gpg-agent.extra /run/user/1000/gnupg/S.gpg-agent.extra"
          ];
        };
      };
    };

    # The ssh-agent module exports SSH_AUTH_SOCK through the fish/bash integration.
    services.ssh-agent.enable = true;
  };
}
