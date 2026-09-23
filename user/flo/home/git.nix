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

    # gh provides the credential helper for github.com (everything lives there
    # now). Wired by hand instead of `programs.gh.gitCredentialHelper` (on by
    # default): that option writes the helper as an absolute /nix/store path,
    # and VS Code copies this file into devcontainers, where the path does not
    # exist and every push logs "gh: not found" before VS Code's own helper
    # takes over. The `!` makes git run the value as a shell command, so `gh`
    # resolves from PATH on both sides (the devcontainer feature ships its
    # own); without it git would look for a `git-credential-gh` executable.
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = false;
    };
    programs.git.settings.credential = {
      "https://github.com".helper = "!gh auth git-credential";
      "https://gist.github.com".helper = "!gh auth git-credential";
    };
  };
}
