# Git identity and credentials. Skipped in devcontainers, where VS Code
# injects the host's git config and credential helper.
{ config, lib, ... }:
{
  config = lib.mkIf (!config.isDevContainer) {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Flo";
        email = "7556827+max06@users.noreply.github.com";
      };
      signing = {
        key = "FAE80AAB28045B8BE8603DBD07E86793BA50B1F5";
        signer = "gpg";
      };
    };

    # gh provides the credential helper for github.com (everything lives there now).
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
